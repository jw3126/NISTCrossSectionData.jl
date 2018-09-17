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

    def download_raw_string(self,Z,
        Emin = None,
        Emax = None,
            ):
        url ="https://physics.nist.gov/PhysRefData/Xcom/Text/chap4.html"
        xpath_link = "/html/body/div[2]/h3/a"
        self.get_url(url)
        el = self.get_xpath(xpath_link)
        el.click()

        print("element compount mixture selection")
        xpath_submit = "/html/body/div[2]/form/p/input[1]"
        el = self.get_xpath(xpath_submit)
        el.click()

        # xpath_atomic_number = "/html/body/form/p[2]/table/tbody/tr[1]/td[1]/p/input[1]"
        el = self.find_name("ZNum")
        print("Z = ", Z, " selected")
        el.send_keys(str(Z))

        if Emin is not None:
            el = self.find_name("WindowXmin")
            el.send_keys(str(Emin))
            print("Emin = {} selected".format(Emin))

        if Emax is not None:
            el = self.find_name("WindowXmax")
            el.send_keys(str(Emax))
            print("Emax = {} selected".format(Emax))

        xpath_submit = "/html/body/form/p[3]/input[1]"
        el = self.get_xpath(xpath_submit)
        el.click()
        print("Z submitted")
        
        el = self.find_name("coherent")
        el.click()

        el = self.find_name("incoherent")
        el.click()

        el = self.find_name("photoelectric")
        el.click()

        el = self.find_name("nuclear")
        el.click()
        
        el = self.find_name("electron")
        el.click()

        el = self.find_name("with")
        el.click()

        el = self.find_name("without")
        el.click()

        xpath_download_data = "/html/body/form[2]/p/input[5]"
        el = self.get_xpath(xpath_download_data)
        el.click()
        ret = self.driver.page_source

        return ret

    def format_raw_string(self, raw):
        lines = deque(raw.split("\n"))
        lines.pop()
        lines.popleft()
        lines.popleft()
        lines.popleft()
        cols = "E CoherentScattering IncoherentScattering PhotoelectricAbsorption PairProductionNuclearField PairProductionElectronField TotalAttenuation TotalAttenuationWithoutCoherentScattering"
        lines.appendleft(cols)
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

    def download_all(self, dir="../../data/XCOM"):
        os.makedirs(dir, exist_ok=True)
        
        for Z in range(1,101):
            filename = "Z{}.csv".format(Z)
            path = os.path.join(dir, filename)
            self.download_and_save_csv(Z=Z, path=path)

if __name__ == "__main__":
    Crawler().download_all()


