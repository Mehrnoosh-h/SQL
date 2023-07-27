WITH temperature_data AS(
  SELECT 
    country AS country_code,
    CAST(year AS INT) AS year_int,
    AVG(temp) AS mean_temp,
  FROM `bigquery-public-data.noaa_gsod.gsod*` AS gsod
  JOIN `bigquery-public-data.noaa_gsod.stations` AS stations ON stations.usaf = gsod.stn
  WHERE country IS NOT NULL
  GROUP BY year, country
)
SELECT 
      country_code,
      DATETIME(year_int,1,1,0,0,0) AS year_datetime,
      year_int,
      mean_temp,
      baseline_temp,
      mean_temp - baseline_temp AS temp_delta
    FROM temperature_data
    JOIN (
        SELECT 
          AVG(mean_temp) AS baseline_temp,
          country_code
        FROM temperature_data
        WHERE year_int>=1973
        GROUP BY country_code
    ) USING (country_code)
    ORDER BY year_int, country_code