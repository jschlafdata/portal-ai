---
sidebar_position: 2
---
 
# Overview 

### Concepts

1. If possible, always find network requests that return a json payload to the website. This exists more often than not, and sometimes can be hidden or hard to find. Spending more time here will save hours from alternative methods.
- https://www.youtube.com/watch?v=PKK7HqD8bS8

**look for:** 
- `/graphql/`
- `*ajax.php`
- `/api/*`
- `*index.json`

2. Order of operations.
- simple requests if possible
- requests_html if page needs javascript rendering
- selenium if requests_html doesn't work or you need to login or grab a generated web token
- selenium --> selenium_wire --> get token --> pass token back to requests
- all selenium as last resort

#### selenium

1. Most bot detection works by reading cookies from the browser and determining if it looks like a typical humans browser activity.
- For this, I usually initialize selenium browsers and then randomly browse, scroll, click pages on the internet unrelated to what I am trying to scrape. I will also choose a path to get to the data I actually care about that I think a person would actually do. Example: google search --> click --> scroll --> click --> search --> find data --> intercept requests.
2. Additionally, you want to use random sleep intervals, random mouse flicks, hyperbolic scrolls. (but not too random lol.)
3. Selenium-Wire allows the ability to intercept network requests, so I always use this to try and find json payloads sent to the site to avoid html parsing and beautiful soup. Selenium + BS4 last last last resort. 

### Webscraper techniques & functions

#### requests

```py title="simple-requests-headers"
def make_headers(json_headers):
    # Static or required headers with default values
    headers = {
        'Connection': 'keep-alive',
        'sec-ch-ua': '" Not;A Brand";v="99", "Google Chrome";v="91", "Chromium";v="91"',
        'Sec-Fetch-Site': 'same-origin',
        'Sec-Fetch-Mode': 'cors',
        'Sec-Fetch-Dest': 'empty',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    }
    
    # Optional keys that are expected to be in the json_headers
    optional_keys = ['authority', 'referer', 'origin', 'content_type', 'x_requested_with', 'accept', 'x-client']
    
    # Add provided headers if they have a non-None value
    for key in optional_keys:
        value = json_headers.get(key)
        if value is not None:
            headers[key.capitalize()] = value  # Capitalize the key as needed
    
    return headers
```


```py title="simple-request-to-bs4"
def co_clubs(notebook_variables):

    variables_from_yml = notebook_variables['blocks']['co_clubs']
    venue_name = variables_from_yml.get('clean_name')

    request = requests.get('https://www.coclubs.com/event-calendar', 
                            headers=make_headers(variables_from_yml['headers']),
                            verify=False)
    
    soup = BeautifulSoup(request.text, 'html.parser')
    soups = soup.find_all('div', class_="cal-info w-dyn-item")
    
    final_items = []
    for soup in soups:

        (venue_name, 
         venue_date) = [ soup.find_all('p')[0].text, 
                         soup.find_all('p')[1].text ]
        
        image = soup.find('a', class_="w-inline-block").find('img')['src']
        artist = soup.find('div', class_="b-show").text
        ticket_link = soup.find('a', class_="w-inline-block")['href']
    
        items = [artist, venue_date, ticket_link, venue_name, image]
        final_items.append(items)
    
    df = pd.DataFrame(final_items)
    df.columns = ['artist','date','link','venue','img_url']
    return df
```


```py title="request-to-json-extraction"
def mishawaka(notebook_variables):
    
    variables_from_yml = notebook_variables['blocks']['mishawaka']
    venue_name = variables_from_yml.get('clean_name')

    data = {
        'data[limit]': '500',
        'data[display]': 'false',
        'data[displayName]': '',
        'data[genre]': '',
        'data[venue]': '',
        'data[month]': '',
        'data[justAnnounced]': '',
        'action': 'loadEtixMonthViewEventPageFn',
    }

    response = requests.post('https://www.themishawaka.com/wp-admin/admin-ajax.php', 
                             headers=make_headers(variables_from_yml['headers']), 
                             data=data)

    df = pd.DataFrame(response.json()['data'])

    def get_title(row):

        row_soup = BeautifulSoup(row, 'html.parser')
        return row_soup.find("div", {"class":"showtitle"}).text

    df['show_title'] = df['title'].map(get_title)

    df = df[['eventdate','show_title','url','imageurl']]

    df.columns = ['Date','Artist','Link','img_url']
    df['Venue'] = venue_name
    
    df = df[['Artist','Date','Link','Venue','img_url']]
    df.columns = ['artist','date','link','venue','img_url']
    
    return df
```


- these are some of the best settings to make selenium  most undetectible. 

```py tite='chrome-driver-settings'

def get_chrome_driver(self):
    # Configure Chrome options
    chrome_options = Options()
    # chrome_options.add_argument("--headless")
    chrome_options.add_argument("--window-size=1920,1080")
    chrome_options.add_argument("--disable-gpu")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-software-rasterizer")
    chrome_options.binary_location = "/usr/bin/google-chrome"  # Adjust as necessary
    chrome_options.add_argument("--disable-blink-features=AutomationControlled")  # Disable Selenium flag

    selenium_wire_options = {
        'custom_headers': self.HEADERS  # Here we set the custom headers
    }
    # Initialize WebDriver with Selenium Wire and WebDriver Manager
    driver = webdriver.Chrome(
        # ChromeDriverManager().install(),
        seleniumwire_options=selenium_wire_options,
        options=chrome_options
    )
    self.driver = driver
    return True
```



### advanced

#### using a tor proxy for infinite undetectible requests

- https://datawookie.dev/blog/2021/10/medusa-multi-headed-tor-proxy/

I like to use this docker image, hosted on a kubernetes pod. The python scripts in this documentation are pinging the internal service cluster IP for the medusa pod to get a new IP address from the pool of tor exits, and then trying to scrape data using that IP.

The way tor works is that new IP's are constantly created and destroyed throughout the day. Most large companies with bot detection maintain lists of bad IP's that are know to be associated with TOR. As such, it is anticipated that some requests fail, and some requests pass. This is because it is impossible for bot blockers to keep up with new tor ip's.

<details>
<summary>Medusa k8s deployment file</summary>
<p>
```yaml tite="medusa-deployment.yml"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: medusa-proxy-deployment
  labels:
    app: medusa-proxy
spec:
  replicas: 1
  selector:
    matchLabels:
      app: medusa-proxy
  template:
    metadata:
      labels:
        app: medusa-proxy
    spec:
      containers:
      - name: medusa-proxy
        image: datawookie/medusa-proxy
        securityContext:
          runAsUser: 0
        ports:
          - containerPort: 8888
```

```py title="Selenium Proxy Routing"
def get_driver():
    # Configure Selenium Wire options
    proxy = 'http://100.65.225.196:8888'

    selenium_wire_options = {
        'proxy' : {
                'http': proxy,
                'https' : proxy
            },
        'custom_headers': {
            'User-Agent': user_agent
        }
    }
    proxies = {
                'http': proxy,
                'https' : proxy
            }
    response = requests.get("http://httpbin.org/ip", proxies=proxies)
    print(f"Current Proxy IP address is: {response.text}")
```
</p>
</details>


