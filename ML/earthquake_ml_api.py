# A FastAPI Endpoint for Earthquake Prediction
from asyncio import get_event_loop
from functools import partial

import database
import earthquake_times
import numpy as np
from fastapi import FastAPI
from sklearn.discriminant_analysis import StandardScaler
from sklearn.gaussian_process import GaussianProcessRegressor
from sklearn.gaussian_process.kernels import RBF, ExpSineSquared, WhiteKernel
from sklearn.kernel_approximation import Nystroem
from sklearn.linear_model import Ridge
from sklearn.pipeline import make_pipeline

app = FastAPI()
model = None
loop = get_event_loop()


@app.get("/predict/{number_of_earthquakes}")
async def predict_earthquake(number_of_earthquakes: int):
    await loop.run_in_executor(None, partial(prediction, number_of_earthquakes))


@app.get("/learn/{number_of_earthquakes}")
async def learn(number_of_earthquakes: int = 100):
    await loop.run_in_executor(None, partial(learn_helper, number_of_earthquakes))


def prediction(number_of_earthquakes: int):
    global model
    if model is None:
        model = learn_helper()
    mydb = database.connect_to_mysql()
    data = np.array(database.fetch_earthquake_data(mydb.cursor(), -1))

    for i in range(len(data)):
        for j in range(len(data[i])):
            if data[i][j] is None:
                data[i][j] = 0.0

    timemodel = earthquake_times.get_model(data)
    predicted_times = earthquake_times.get_predicted_times(
        timemodel, len(data) + 1, number_of_earthquakes
    )
    future_predictions = model.predict(predicted_times.reshape(-1, 1))

    database.write_predictions_only_mag(
        mydb.cursor(),
        [
            (prediction, predicted_times[i])
            for i, prediction in enumerate(future_predictions)
        ],
    )
    mydb.commit()
    mydb.close()
    return True


def learn_helper(number_of_earthquakes: int = 100):
    global model
    mydb = database.connect_to_mysql()
    data = np.array(
        database.fetch_earthquake_data(mydb.cursor(), number_of_earthquakes)
    )

    np.where(data == None, 0.0, data).astype(float)

    X = [[data[i][1]] for i in range(len(data))]
    y = [float(0 if data[i][0] is None else data[i][0]) for i in range(len(data))]
    kernel = (
        RBF(length_scale=0.5, length_scale_bounds=(1e-2, 10.0))
        + ExpSineSquared(
            length_scale=1.0, periodicity=10.0, periodicity_bounds=(1e-10, 1e10)
        )
        + WhiteKernel(noise_level=1e-3)
    )
    model = make_pipeline(
        StandardScaler(),
        Nystroem(kernel=kernel, n_components=100, random_state=42, gamma=0.5),
        Ridge(alpha=1e-12, random_state=42),
        memory="/tmp/cache",
    )
    model.fit(X, y)
    return model
