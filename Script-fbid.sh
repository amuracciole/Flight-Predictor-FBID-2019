#!/bin/bash

count=0
total_40=40
total_35=35
total_5=5
pstr="[=======================================================================]"

# Inicializando...
echo "\n---> ¡¡ INICIALIZANDO SCRIPT PARA PREDICTOR DE VUELOS - FBID 2019 !! <---"
echo "           (Trabajo FBID de Andrés Muracciole e Israel Vázquez)\n"
sleep 2

# Bajar contenedores en caso de que ya existan
echo "\n        ---> PARANDO Y ELIMINANDO LOS CONTENEDORES EN CASO DE TENERLOS ACTIVOS... <---"
echo "---> (Los mensajes de Error refieren a que no existe el contenedor. No es un error en si mismo) <---\n"
# docker stop $(docker ps -a -q)
docker stop zookeeper
docker stop kafka
docker stop mongo
docker stop web
docker stop spark-master
docker stop spark-worker-1
# docker rm $(docker ps -a -q)
docker rm zookeeper
docker rm kafka
docker rm mongo
docker rm web
docker rm spark-master
docker rm spark-worker-1

# Descargar imágenes en caso de no tenerlas y levantar el dockerfile
echo "\n---> DESCARGANDO IMÁGENES NECESARIAS... <---\n"
docker pull wurstmeister/zookeeper:3.4.6
docker pull wurstmeister/kafka:2.12-2.3.0
docker pull mongo:4.2
cd /Users/andresmuracciole/Desktop/BIGDATA_Project/practica_big_data_2019-master
docker build -t web .
docker pull bde2020/spark-master:2.4.4-hadoop2.7
docker pull bde2020/spark-worker:2.4.4-hadoop2.7

# Se levanta el docker-compose
Docker-compose up -d
echo "\n---> SE ESTÁN DESPLEGANDO LOS CONTENEDORES... <---\n"

while [ $count -lt $total_40 ]; do
  sleep 1 
  count=$(( $count + 1 ))
  pd=$(( $count * 73 / $total_40 ))
  printf "\r%3d.%1d%% %.${pd}s" $(( $count * 100 / $total_40 )) $(( ($count * 1000 / $total_40) % 10 )) $pstr
done

# Se crea la base de datos y se realiza el aprendizaje
echo "\n\n---> GRACIAS POR ESPERAR <---\n"
sleep 1
./resources/import_distances.sh
Docker exec -it -d spark-worker-1 bash ./spark/bin/spark-submit --class es.upm.dit.ging.predictor.MakePrediction --deploy-mode client --packages org.mongodb.spark:mongo-spark-connector_2.11:2.3.2,org.apache.spark:spark-sql-kafka-0-10_2.11:2.4.0  /prediccion_vuelos/flight_prediction/target/scala-2.11/flight_prediction_2.11-0.1.jar
echo "\n---> SE ESTÁ REALIZANDO EL APRENDIZAJE... <---\n"

count=0
while [ $count -lt $total_35 ]; do
  sleep 1 # this is work
  count=$(( $count + 1 ))
  pd=$(( $count * 73 / $total_35 ))
  printf "\r%3d.%1d%% %.${pd}s" $(( $count * 100 / $total_35 )) $(( ($count * 1000 / $total_35) % 10 )) $pstr
done

echo "\n\n---> A CONTINUACIÓN SE ABRIRÁ EL EXPLORADOR PARA QUE PUEDA REALIZAR LA PREDICCIÓN <---\n"

count=0
while [ $count -lt $total_5 ]; do
  sleep 1 # this is work
  count=$(( $count + 1 ))
  pd=$(( $count * 73 / $total_5 ))
  printf "\r%3d.%1d%% %.${pd}s" $(( $count * 100 / $total_5 )) $(( ($count * 1000 / $total_5) % 10 )) $pstr
done

# Se abre el explorador para hacer la consulta
open http://localhost:5000/flights/delays/predict_kafka
docker exec -it mongo mongo
