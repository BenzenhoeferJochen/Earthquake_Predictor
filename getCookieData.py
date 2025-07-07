import browser_cookie3

cookies = browser_cookie3.firefox(domain_name=".vocareum.com")
cookie_dict = {}
for cookie in cookies:
    cookie_dict[cookie.name] = cookie.value
print(
    f"""{{"result": "userid={cookie_dict["userid"]}; logintoken={cookie_dict["logintoken"]}; usertoken={cookie_dict["usertoken"]}; t2fausers={cookie_dict["t2fausers"]}; currentassignment={cookie_dict["currentassignment"]}; currentcourse_id={cookie_dict["currentcourse_id"]}; PHPSESSID={cookie_dict["PHPSESSID"]}; userassignment={cookie_dict["userassignment"]}; tokenExpire={cookie_dict["tokenExpire"]}; usingLTI=1; currentcourse_id={cookie_dict["currentcourse_id"]}"}}"""
)
