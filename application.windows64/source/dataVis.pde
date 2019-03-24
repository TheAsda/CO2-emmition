PImage mapimg;

int clat = 23;
int clon = 12;

int ww = 1280;
int hh = 720;

float zoom = 1.4;
JSONArray  json;
Table table;
float mercX(float lon) {
  lon = radians(lon);
  float a = (256 / PI) * pow(2, zoom);
  float b = lon + PI;
  return a * b;
}

float mercY(float lat) {
  lat = radians(lat);
  float a = (256 / PI) * pow(2, zoom);
  float b = tan(PI / 4 + lat / 2);
  float c = PI - log(b);
  return a * c;
}

String checkCountry(String country) {
  switch(country) {
  case "france (including monaco)":
    return "france";
  case "italy (including san marino)":
    return "italy";
  case "japan (excluding the ruyuku islands)":
    return "japan";
  case "peninsular malaysia":
    return "malaysia";
  case "ussr":
    return "russian federation";
  case "yugoslavia (former socialist federal republic)":
    return "macedonia";
  case "china (mainland)":
    return "china";
  case "czechoslovakia":
    return "czech republic";
  case "democratic republic of the congo (formerly zaire)":
    return "the democratic republic of the congo";
  case "myanmar (formerly burma)":
    return "myanmar";
  case "french indo-china":
    return "french guiana";
  case "brunei (darussalam)":
    return "brunei darussalam";
  case "hong kong special adminstrative region of china":
    return "hong kong";
  case"federal republic of germany":
    return "germany";
  case "former german democratic republic":
    return "germany";
  case "democratic people s republic of korea":
    return "republic of korea";
  case "former yemen":
    return "yemen";
  default:
    return country;
  }
}

class Country {
  String name;
  float lat, lon, x, y, capita;
  Country(String name, float lat, float lon, float x, float y, float capita) {
    this.name=name;
    this.lat=lat;
    this.lon=lon;
    this.x=x;
    this.y=y;
    this.capita=capita;
  }
}

class Years {
  int year;
  float maxCapita;
  ArrayList<Country>  countries=new ArrayList<Country>();
  Years(int year, String name, float lat, float lon, float x, float y, float capita) {
    this.year=year;
    this.maxCapita=capita;
    this.countries.add(new Country(name, lat, lon, x, y, capita));
  }
  void add(String name, float lat, float lon, float x, float y, float capita) {
    if (this.maxCapita<capita) {
      this.maxCapita=capita;
    }
    this.countries.add(new Country(name, lat, lon, x, y, capita));
  }
}

class Main {
  ArrayList<Years> arr=new ArrayList<Years>();
  void add(int year, String name, float lat, float lon, float x, float y, float capita) {
    if (this.arr.size()==0) {
      this.arr.add(new Years(year, name, lat, lon, x, y, capita));
    }
    for (int i=0; i<this.arr.size(); i++) {
      if (this.arr.get(i).year==year) {
        this.arr.get(i).add(name, lat, lon, x, y, capita);
        return;
      }
    }
    this.arr.add(new Years(year, name, lat, lon, x, y, capita));
  }
}

Main Data=new Main();

void setup() {
  float cx = mercX(clon);
  float cy = mercY(clat);
  size(1280, 720);
  String url = "https://api.mapbox.com/styles/v1/mapbox/navigation-preview-day-v2/static/" +
    clon + "," + clat + "," + zoom + "/" +
    ww + "x" + hh +
    "?access_token=pk.eyJ1IjoiY29kaW5ndHJhaW4iLCJhIjoiY2l6MGl4bXhsMDRpNzJxcDh0a2NhNDExbCJ9.awIfnl6ngyHoB3Xztkzarw";
  mapimg = loadImage(url, "jpg");
  json = loadJSONArray("https://pkgstore.datahub.io/JohnSnowLabs/estimates-emissions-of-co2-at-country-and-global-level-starting-1751/estimates-emissions-of-co2-at-country-and-global-level-starting-1751-csv_json/data/8b0dd8d507dbe5a7d9c9b571e76e057c/estimates-emissions-of-co2-at-country-and-global-level-starting-1751-csv_json.json");
  table=loadTable("countries.csv", "header");
  for (int i =0; i<table.getRowCount(); i++) {
    table.setString(i, "Country", table.getString(i, "Country").toLowerCase());
  }
  boolean f=true;
  for (int i =0; i<json.size(); i++) {
    JSONObject obj=json.getJSONObject(i);
    String country=obj.getString("Country");
    float capita=0;
    String year=obj.getString("Year");
    year=year.split("-")[0];
    //println(year);
    try {
      capita=obj.getFloat("Country_Per_Capita_Per_Year");
    }
    catch(RuntimeException err) {
      f=false;
    }
    if (f==true) {
      //println(capita);
      String rightCountry=country.toLowerCase();
      rightCountry=checkCountry(rightCountry);
      //println(rightCountry);
      TableRow row=table.findRow(rightCountry, "Country");
      try {
        float lat=row.getFloat("Latitude (average)");
        float lon=row.getFloat("Longitude (average)");
        float x = mercX(lon) - cx;
        float y = mercY(lat) - cy;
        if (x < - width/2) {
          x += width;
        } else if (x > width / 2) {
          x -= width;
        }
        Data.add(int(year), country, lat, lon, x, y, capita);
        //println(year);
      }
      catch(NullPointerException err) {
        if(i<5)
        println(rightCountry);
      }
    }
    f=true;
  }
}

float size=25;
int index=0;

void draw() {
  translate(width / 2, height / 2);
  imageMode(CENTER);
  image(mapimg, 0, 0);
  textSize(60);
  text(Data.arr.get(index).year, 0, 300);
  noStroke();
  fill(154, 13, 74, 200);
  for (int i=0; i<Data.arr.get(index).countries.size(); i++) {
    float percent=(Data.arr.get(index).countries.get(i).capita/Data.arr.get(index).maxCapita);
    ellipse(Data.arr.get(index).countries.get(i).x, Data.arr.get(index).countries.get(i).y, size*percent, size*percent);
  }
  //noLoop();
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      if (index+1<Data.arr.size())
        index++;
    } else if (keyCode == RIGHT) {
      if (index-1>=0)
        index--;
    }
  }
}
