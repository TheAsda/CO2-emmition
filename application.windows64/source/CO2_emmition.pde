PImage mapimg;

final int clat = 23;
final int clon = 12;

final int ww = 1280;
final int hh = 720;

final float zoom = 1.4;

final String fields[]={"Country_Per_Capita_Per_Year", "Country_Cement_Per_Year", "Country_Gas_Fuel_Per_Year", "Country_Solid_Fuel_Per_Year", "Country_Liquid_Fuel_Per_Year"};
final String texts[]={"Per Capita", "Cement", "Gas Fuel", "Solid Fuel", "Liquid Fuel"};

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
  float lat, lon, x, y, capita, cem, gas, solid, liq;
  Country(String name, float lat, float lon, float x, float y, float capita, float cem, float gas, float solid, float liq) {
    this.name=name;
    this.lat=lat;
    this.lon=lon;
    this.x=x;
    this.y=y;
    this.capita=capita;
    this.cem=cem;
    this.gas=gas;
    this.solid=solid;
    this.liq=liq;
  }
}

class Years {
  int year;
  ArrayList<Country>  countries=new ArrayList<Country>();
  Years(int year, String name, float lat, float lon, float x, float y, float capita, float cem, float gas, float solid, float liq) {
    this.year=year;
    this.countries.add(new Country(name, lat, lon, x, y, capita, cem, gas, solid, liq));
  }
  void add(String name, float lat, float lon, float x, float y, float capita, float cem, float gas, float solid, float liq) {
    this.countries.add(new Country(name, lat, lon, x, y, capita, cem, gas, solid, liq));
  }
}

class Main {
  ArrayList<Years> arr=new ArrayList<Years>();
  float maxCapita, maxCem, maxGas, maxSolid, maxLiq;
  void add(int year, String name, float lat, float lon, float x, float y, float capita, float cem, float gas, float solid, float liq) {
    if (this.arr.size()==0) {
      this.maxCapita=capita;
      this.maxCem=cem;
      this.maxGas=gas;
      this.maxSolid=solid;
      this.maxLiq=liq;
      this.arr.add(new Years(year, name, lat, lon, x, y, capita, cem, gas, solid, liq));
    }
    if (this.maxCapita<capita) {
      this.maxCapita=capita;
    }
    if (this.maxCem<cem) {
      this.maxCem=cem;
    }
    if (this.maxGas<gas) {
      this.maxGas=gas;
    }
    if (this.maxSolid<solid) {
      this.maxSolid=solid;
    }
    if (this.maxLiq<liq) {
      this.maxLiq=liq;
    }
    for (int i=0; i<this.arr.size(); i++) {
      if (this.arr.get(i).year==year) {
        this.arr.get(i).add(name, lat, lon, x, y, capita, cem, gas, solid, liq);
        return;
      }
    }
    this.arr.add(new Years(year, name, lat, lon, x, y, capita, cem, gas, solid, liq));
  }
}

Main Data=new Main();


void setup() {
  final float cx = mercX(clon);
  final float cy = mercY(clat);
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
  for (int i =0; i<json.size(); i++) {
    JSONObject obj=json.getJSONObject(i);
    String country=obj.getString("Country");
    float capita=0, cem=0, gas=0, solid=0, liq=0;
    String year=obj.getString("Year");
    year=year.split("-")[0];
    capita=obj.getFloat(fields[0], 0);
    cem=obj.getFloat(fields[1], 0);
    gas=obj.getFloat(fields[2], 0);
    solid=obj.getFloat(fields[3], 0);
    liq=obj.getFloat(fields[4], 0);

    String rightCountry=country.toLowerCase();
    rightCountry=checkCountry(rightCountry);
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
      Data.add(int(year), country, lat, lon, x, y, capita, cem, gas, solid, liq);
    }
    catch(NullPointerException err) {
    }
  }
}

final float bubbleSize=80;
int index=0, index2=0;

void draw() {
  translate(width / 2, height / 2);
  imageMode(CENTER);
  image(mapimg, 0, 0);
  textSize(60);
  textAlign(CENTER);
  text(Data.arr.get(index).year, 0, 300);
  text(texts[index2], 0, -300);
  noStroke();
  fill(154, 13, 74, 200);
  float percent=0;
  for (int i=0; i<Data.arr.get(index).countries.size(); i++) {
    switch (index2) {
    case 0:
      percent =(Data.arr.get(index).countries.get(i).capita/Data.maxCapita);
      break;
    case 1:
      percent =(Data.arr.get(index).countries.get(i).cem/Data.maxCem);
      break;
    case 2:
      percent =(Data.arr.get(index).countries.get(i).gas/Data.maxGas);
      break;
    case 3:
      percent =(Data.arr.get(index).countries.get(i).solid/Data.maxSolid);
      break;
    case 4:
      percent =(Data.arr.get(index).countries.get(i).liq/Data.maxLiq);
      break;
    }
    ellipse(Data.arr.get(index).countries.get(i).x, Data.arr.get(index).countries.get(i).y, bubbleSize*percent, bubbleSize*percent);
  }
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
    if (keyCode == UP) {
      if (index2+1<5)
        index2++;
    } else if (keyCode == DOWN) {
      if (index2-1>=0)
        index2--;
    }
  }
}
