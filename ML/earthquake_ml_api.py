# A FastAPI Endpoint for Earthquake Prediction
from asyncio import get_event_loop
from functools import partial

import database
import earthquake_times
import numpy as np
import tensorflow as tf
import tensorflow_probability as tfp
from fastapi import FastAPI
from sklearn.discriminant_analysis import StandardScaler
from sklearn.ensemble import GradientBoostingRegressor

app = FastAPI()
model = None
loop = get_event_loop()


tfd = tfp.distributions
tfk = tf.keras
tfpl = tf.keras.layers

@app.get("/")
def root():
    return {"message": "Welcome to the Earthquake Predictor API"}

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

    # Clean data
    for i in range(len(data)):
        for j in range(len(data[i])):
            if data[i][j] is None:
                data[i][j] = 0.0

    timemodel = earthquake_times.get_model(data)
    predicted_times = earthquake_times.get_predicted_times(
        timemodel, len(data) + 1, number_of_earthquakes
    )

    # Prepare features for prediction based on the model type
    if isinstance(model, GradientBoostingRegressor):
        # For GBR, prepare all features
        future_features = []
        for i in range(len(predicted_times)):
            features = []
            # Time feature
            features.append((predicted_times[i] - data[0][1]) / (1000 * 60 * 60 * 24))

            # For other features, use the average from historical data or last known values
            if len(data[0]) > 2:  # tsunami
                features.append(data[i][2] if data[i][2] is not None else 0.0)
            if len(data[0]) > 3:  # sig
                features.append(data[i][3] if data[i][3] is not None else 0.0)
            if len(data[0]) > 4:  # rms
                features.append(data[i][4] if data[i][4] is not None else 0.0)
            if len(data[0]) > 7:  # location
                features.append(data[i][5])  # last known longitude
                features.append(data[i][6])  # last known latitude
                features.append(data[i][7])  # last known depth

            future_features.append(features)

        # Scale features using the same scaler
        X_pred = np.array(future_features)
        X_pred_scaled = (
            model.scaler.transform(X_pred) if hasattr(model, "scaler") else X_pred
        )
        future_predictions = model.predict(X_pred_scaled)
    else:
        # For neural network, prepare features based on input shape
        if hasattr(model, "input_shape") and model.input_shape[1] > 1:
            # Multi-feature input
            future_features = []
            for i in range(len(predicted_times)):
                features = []
                # Time feature
                features.append(
                    (predicted_times[i] - data[0][1]) / (1000 * 60 * 60 * 24)
                )

                # Add placeholder values for other features
                for _ in range(model.input_shape[1] - 1):
                    features.append(0.0)

                future_features.append(features)
            X_pred = np.array(future_features)
            X_pred_scaled = (
                model.scaler.transform(X_pred) if hasattr(model, "scaler") else X_pred
            )
            future_predictions = model.predict(X_pred_scaled)
        else:
            # Single feature input (time only)
            predicted_times_scaled = []
            for i in range(len(predicted_times)):
                predicted_times_scaled.append(
                    (predicted_times[i] - data[0][1]) / (1000 * 60 * 60 * 24)
                )
            X_pred = np.array(predicted_times_scaled).reshape(-1, 1)
            X_pred_scaled = (
                model.scaler.transform(X_pred) if hasattr(model, "scaler") else X_pred
            )
            future_predictions = model.predict(X_pred_scaled)

    # Format predictions for database
    predictions_for_db = []
    for i, pred in enumerate(future_predictions):
        # Handle different prediction formats
        if isinstance(pred, np.ndarray):
            mag = (pred[0] * -1.5) + 8
        else:
            mag = (pred * -1.5) + 8
        predictions_for_db.append((float(mag), predicted_times[i]))

    # Write predictions to database
    database.write_predictions_only_mag(mydb.cursor(), predictions_for_db)
    mydb.commit()
    mydb.close()
    return True


def learn_helper(number_of_earthquakes: int = 100):
    global model
    mydb = database.connect_to_mysql()
    data = np.array(
        database.fetch_earthquake_data(mydb.cursor(), number_of_earthquakes)
    )

    # Clean and preprocess data
    data = np.where(data == None, 0.0, data).astype(float)

    # Extract more features from the data
    # Time features (normalized days since first earthquake)
    time_features = np.array(
        [[(data[i][1] - data[0][1]) / (1000 * 60 * 60 * 24)] for i in range(len(data))]
    )

    # Extract additional features if available (tsunami, sig, rms, longitude, latitude, depth)
    additional_features = []
    for i in range(len(data)):
        features = []
        # Add time feature
        features.append((data[i][1] - data[0][1]) / (1000 * 60 * 60 * 24))

        # Add tsunami indicator if available (column 2)
        if len(data[i]) > 2:
            features.append(data[i][2])

        # Add significance if available (column 3)
        if len(data[i]) > 3:
            features.append(data[i][3])

        # Add RMS if available (column 4)
        if len(data[i]) > 4:
            features.append(data[i][4])

        # Add location features if available (columns 5, 6, 7)
        if len(data[i]) > 7:
            features.append(data[i][5])  # longitude
            features.append(data[i][6])  # latitude
            features.append(data[i][7])  # depth

        additional_features.append(features)

    # Use all available features if we have them, otherwise just use time
    if len(additional_features[0]) > 1:
        X = np.array(additional_features)
        print(f"Using {X.shape[1]} features for training")
    else:
        X = time_features
        print("Using only time features for training")

    # Target variable - earthquake magnitude
    y = np.array(
        [float(0 if data[i][0] is None else data[i][0]) for i in range(len(data))]
    )

    print("X shape:", X.shape)
    print("Y shape:", y.shape)
    print("Sample X:", X[-5:])
    print("Sample Y:", y[-5:])

    # Create a more sophisticated model
    # 1. Use feature scaling for better convergence
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)

    # 2. Try an ensemble approach with GradientBoostingRegressor
    if X.shape[0] > 100:  # If we have enough data, use GBR
        print("Using Gradient Boosting Regressor...")
        model = GradientBoostingRegressor(
            n_estimators=200,
            learning_rate=0.1,
            max_depth=10,
            min_samples_split=5,
            min_samples_leaf=2,
            max_features="sqrt",
            subsample=0.1,
            random_state=42,
        )
        model.fit(X_scaled, y)
        print("Feature importances:", model.feature_importances_)
    else:  # Otherwise use a deep neural network with regularization
        print("Using Deep Neural Network...")
        input_dim = X.shape[1]
        tfk.backend.set_floatx("float64")

        # Create a more complex model with regularization to prevent overfitting
        model = tfk.Sequential(
            [
                tfk.layers.InputLayer(input_shape=[input_dim]),
                tfk.layers.BatchNormalization(),
                tfk.layers.Dense(
                    512,
                    activation="relu",
                    kernel_regularizer=tfk.regularizers.l2(0.001),
                ),
                tfk.layers.Dropout(0.3),
                tfk.layers.Dense(
                    256,
                    activation="relu",
                    kernel_regularizer=tfk.regularizers.l2(0.001),
                ),
                tfk.layers.Dropout(0.3),
                tfk.layers.Dense(
                    128,
                    activation="relu",
                    kernel_regularizer=tfk.regularizers.l2(0.001),
                ),
                tfk.layers.Dropout(0.2),
                tfk.layers.Dense(
                    64, activation="relu", kernel_regularizer=tfk.regularizers.l2(0.001)
                ),
                tfk.layers.Dense(1, activation="linear"),
            ]
        )

        # Use a learning rate schedule for better convergence
        lr_schedule = tfk.optimizers.schedules.ExponentialDecay(
            initial_learning_rate=0.001, decay_steps=100, decay_rate=0.9
        )

        model.compile(
            optimizer=tf.optimizers.Adam(learning_rate=lr_schedule),
            loss="mean_squared_error",
            metrics=["mae"],
        )

        # Use early stopping to prevent overfitting
        early_stopping = tfk.callbacks.EarlyStopping(
            monitor="val_loss", patience=10, restore_best_weights=True
        )

        # Train with validation split
        print("Starting training with data size:", len(X))
        model.fit(
            x=X_scaled,
            y=y,
            epochs=100,
            batch_size=32,
            validation_split=0.2,
            callbacks=[early_stopping],
            verbose=1,
        )

        # Save the scaler with the model for future predictions
        model.scaler = scaler

    return model
