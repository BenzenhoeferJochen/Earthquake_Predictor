# 🌍 Earthquake Predictor

**Earthquake Predictor** is a cloud-based application that leverages [Node-RED](https://nodered.org/) to process and visualize real-time data with the goal of predicting earthquakes. This project deploys Node-RED on an AWS EC2 instance using [Terraform](https://www.terraform.io/) for infrastructure as code (IaC).

> ⚠️ Earthquake prediction logic is a work in progress. Currently, this repository focuses on setting up the infrastructure and running the base Node-RED environment.

---

## 🚀 Project Overview

This project provides:

- Terraform code to provision an EC2 instance on AWS
- Automated setup of Node-RED on the EC2 instance
- Secure and configurable deployment
- A foundation for developing earthquake prediction logic using real-time data streams

---

## 🧱 Architecture

```

+----------------------+        +-----------------------------+
\|     Terraform        |        |         AWS EC2 Instance    |
\|  (Infrastructure IaC)| -----> |         Linux + Node-RED    |
+----------------------+        +-----------------------------+

````

---

## 🛠️ Getting Started

### Prerequisites

- AWS account with access credentials
- [Terraform](https://developer.hashicorp.com/terraform/install) installed

### Clone the Repository

```bash
git clone https://github.com/your-username/earthquake-predictor.git
cd earthquake-predictor
````
### Set the credentials

create a credentials file on this top Level and paste in your AWS credentials.
The File will be ignored by git.

### Terraform Initialization and Deployment

```bash
terraform init
terraform plan
terraform apply
```

Once the apply step is complete, note the public IP address of your EC2 instance.

### Access Node-RED

Open your browser and go to:

```
http://<EC2-PUBLIC-IP>:1880
```

---

## 🧪 Future Plans

* Integrate real-time seismic data sources (e.g., USGS, EMSC)
* Develop predictive models using historical and live data
* Deploy prediction logic via Node-RED flows
* Visualization dashboards

---

## 🔐 Security Notes

* For production use, configure HTTPS and authentication in Node-RED.
* Restrict access to the EC2 instance via Security Groups.

---

## 📂 Project Structure (WIP)

```
📦Earthquake_Predictor
 ┣ 📂.git
 ┣ 📂.terraform
 ┣ 📜.gitignore
 ┣ 📜.terraform.lock.hcl
 ┣ 📜.tfvars
 ┣ 📜cookieData.tf
 ┣ 📜credentials
 ┣ 📜ec2.tf
 ┣ 📜getCookieData.py
 ┣ 📜igw.tf
 ┣ 📜LICENSE
 ┣ 📜main.tf
 ┣ 📜nodered.service
 ┣ 📜README.md
 ┣ 📜refreshLab.service
 ┣ 📜refreshLab.sh
 ┣ 📜refreshLab.timer
 ┣ 📜sg.tf
 ┣ 📜subnet.tf
 ┣ 📜terraform.tfstate
 ┣ 📜terraform.tfstate.backup
 ┣ 📜user_data.sh
 ┣ 📜vars.tf
 ┗ 📜vpc.tf
```

---

## 📜 License

This project is licensed under the Apache License.

---

## 🤝 Contributing

Contributions are welcome! Please open issues or pull requests.

---

## 📫 Contact

For questions or feedback, open an issue or email: \[[jochen.benzenhoefer@it-tem.de](mailto:jochen.benzenhoefer@it-tem.de)]
