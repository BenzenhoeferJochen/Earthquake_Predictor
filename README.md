# 🌍 Earthquake Predictor

**Earthquake Predictor** is a cloud-based application that leverages machine learning to predict earthquakes using historical seismic data. The system combines [Node-RED](https://nodered.org/) for data visualization and flow management with a dedicated ML backend for predictions, all deployed on AWS infrastructure using [Terraform](https://www.terraform.io/).

## 🚀 Project Overview

This project provides:

- Complete AWS infrastructure as code using Terraform
- Scalable architecture with auto-scaling groups
- Frontend Node-RED interface for visualization and data management
- Backend ML service for earthquake prediction
- MySQL database for storing historical and predicted earthquake data
- Shared EFS storage for persistent Node-RED flows

## 🧱 Architecture

![AWS Architecture of the Earthquake Predictor](./Earthquake_Predictor.svg)
<img src="./Earthquake_Predictor.svg">

## 🛠️ Getting Started

### Prerequisites

- AWS account with access credentials
- [Terraform](https://developer.hashicorp.com/terraform/install) installed (v6.0.0+)
- Basic knowledge of AWS services

### Setup

1. **Clone the Repository**

```bash
git clone https://github.com/your-username/earthquake-predictor.git
cd earthquake-predictor
```

2. **Configure AWS Credentials**

Create a `credentials` file in the project root directory with your AWS credentials:

```
[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY
aws_session_token= YOUR_SESSION_TOKEN
```

3. **Configure Variables**

Create a `.tfvars` file with your configuration:

```
DB_USER = "DB-User"
DB_PASSWORD = "your-secure-password"
DB_DATABASE = "DB-Database"
CREDENTIAL_SECRET = "your-secret-for-Node-Red"
```

4. **Deploy Infrastructure**

```bash
terraform init
terraform plan
terraform apply
```

5. **Access the Application**

After deployment completes, Terraform will output the DNS names for both frontend and backend services:

- Node-RED Interface: `http://<Frontend_Load_Balancer_DNS>:1880`
- ML API Endpoint: `http://<Backend_Load_Balancer_DNS>:3000`

## 🔬 Machine Learning Model

The project uses a Gaussian Process Regressor model to predict earthquake magnitudes based on historical data. The ML pipeline includes:

- Data preprocessing with StandardScaler
- Feature approximation using Nystroem method
- Ridge regression for prediction
- Time series analysis for earthquake timing prediction

API endpoints:
- `/predict/{number_of_earthquakes}` - Generate predictions for future earthquakes
- `/learn/{number_of_earthquakes}` - Train the model on historical data

## 📊 Data Flow

1. Historical earthquake data is stored in the MySQL database
2. The ML backend processes this data to train prediction models
3. Predictions are stored back in the database
4. Node-RED provides visualization and user interface for the system

## 🔐 Security Features

- Private subnets for database and backend services
- Security groups with least privilege access
- SSH access restricted to authorized IPs
- Auto-scaling for high availability and fault tolerance

## 🧪 Future Enhancements

- Integration with additional seismic data sources (USGS, EMSC)
- Advanced ML models incorporating more geological features
- Real-time alerting system
- Geographic visualization of predictions
- Mobile application for alerts

## 📂 Project Structure

```
📦Earthquake_Predictor
 ┣ 📂ML                      # Machine Learning components
 ┃ ┣ 📜database.py           # Database connection and queries
 ┃ ┣ 📜earthquake_ml_api.py  # FastAPI endpoints for predictions
 ┃ ┣ 📜earthquake_times.py   # Time series analysis for earthquakes
 ┃ ┣ 📜prediction.service    # Systemd service for ML API
 ┃ ┗ 📜requirements.txt      # Python dependencies
 ┣ 📂Node-Red                # Node-RED flows and configuration
 ┃ ┣ 📜flows.json            # Node-RED flow definitions
 ┃ ┗ 📜settings.js           # Node-RED settings
 ┣ 📜autoScaling.tf          # Auto-scaling groups configuration
 ┣ 📜db.tf                   # MySQL RDS configuration
 ┣ 📜efs.tf                  # Elastic File System configuration
 ┣ 📜loadBalancer.tf         # Application Load Balancer setup
 ┣ 📜main.tf                 # Main Terraform configuration
 ┣ 📜sg.tf                   # Security Groups configuration
 ┣ 📜subnet.tf               # VPC and subnet configuration
 ┣ 📜user_data_Backend.sh    # Backend instance initialization script
 ┣ 📜user_data_Frontend.sh   # Frontend instance initialization script
 ┗ 📜vpc.tf                  # VPC configuration
```

## 🔧 Troubleshooting

- **Node-RED not accessible**: Check security groups and load balancer health checks
- **ML API errors**: Verify database connectivity and check logs with `journalctl -u prediction.service`
- **Database connection issues**: Ensure security groups allow traffic on port 3306

## 📜 License

This project is licensed under the Apache License 2.0.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📫 Contact

For questions or feedback, please open an issue or email: [jochen.benzenhoefer@it-tem.de](mailto:jochen.benzenhoefer@it-tem.de)