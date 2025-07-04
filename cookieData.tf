data "external" "getCookies" {
  program = ["python", "${path.module}/getCookieData.py"]
}
