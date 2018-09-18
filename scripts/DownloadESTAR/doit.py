from selenium.webdriver import Firefox
from selenium.webdriver.firefox.options import Options
from tenacity import retry, stop_after_delay, wait_random
from collections import deque
import os

# search_form = browser.find_element_by_id('search_form_input_homepage')
# search_form.send_keys('real python')
# search_form.submit()
# 
# results = browser.find_elements_by_class_name('result')
# print(results)
# print(results[0].text)
# 
# browser.close()

class Crawler:

    def __init__(self):
        opts = Options()
        opts.set_headless()
        assert opts.headless  # operating in headless mode
        self.driver = Firefox(options=opts)
        self.form_url = "https://physics.nist.gov/PhysRefData/Star/Text/ESTAR-t.html"

    def download_raw_string(self,Z):
        xpath_select = "/html/body/form/select/option[{}]".format(Z+1)
        xpath_submit = "/html/body/form/p[4]/input[1]"
        self.get_url(self.form_url)
        self.get_xpath(xpath_select).click()
        self.get_xpath(xpath_submit).click()
        ret = self.driver.page_source
        return ret

    def format_raw_string(self, raw):
        lines = raw.splitlines()
        table1 = lines[4]
        table2 = lines[5]
        lines1 = table1.split("<br>")[10:-1]
        lines2 = table2.split("<br>")
        lines = lines1 + lines2
        lines = [l for l in lines if l.strip() != ""]

        cols = "E Collision Radiative Total CSDA RadiationYield DensityEffect"
        lines = [cols, *lines]
        lines = [", ".join(line.split()) for line in lines]
        s = "\n".join(lines)
        return s


    def download_and_save_csv(self, path, Z,  ignore_existing=True, **kw):
        print("download_and_save_csv(path={}, Z={})".format(path,Z))
        if ignore_existing and os.path.exists(path):
            print("path={}, Z={} exists already, skipping.".format(path,Z))
            return ""

        s = self.download_raw_string(Z=Z, **kw)
        s = self.format_raw_string(s)
        with open(path, "w") as file:
            file.write(s)
        return s


    @retry(stop=stop_after_delay(10), wait=wait_random(min=0.1, max=2))
    def get_xpath(self, xpath):
        print("try get_xpath({})".format(xpath))
        el = self.driver.find_element_by_xpath(xpath)
        return el


    @retry(stop=stop_after_delay(10), wait=wait_random(min=0.1, max=2))
    def find_name(self, name):
        print("try find_name({})".format(name))
        el = self.driver.find_element_by_name(name)
        return el


    @retry(stop=stop_after_delay(10), wait=wait_random(min=0.1, max=2))
    def get_url(self, url):
        print ("try get_url({})", url)
        ret = self.driver.get(url)
        print("reached url ", url)
        return ret

    def download_all(self, dir="../../data/ESTAR"):
        os.makedirs(dir, exist_ok=True)
        
        for Z in range(1,101):
            filename = "Z{}.csv".format(Z)
            path = os.path.join(dir, filename)
            self.download_and_save_csv(Z=Z, path=path)

if __name__ == "__main__":
    Crawler().download_all()
