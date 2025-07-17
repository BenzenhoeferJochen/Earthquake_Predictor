from sklearn import linear_model


def get_model(historical_data: list) -> linear_model.LinearRegression:
    return linear_model.LinearRegression().fit(
        [[i] for i in range(len(historical_data))],
        [historical_data[i][1] for i in range(len(historical_data))],
    )


def get_predicted_times(
    timemodel: linear_model.LinearRegression,
    next_data_point: int,
    number_of_predictions: int = 100,
) -> list:
    return timemodel.predict(
        [[next_data_point + i] for i in range(0, number_of_predictions)]
    )
