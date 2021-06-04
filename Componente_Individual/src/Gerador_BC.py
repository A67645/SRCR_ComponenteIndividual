import pandas as pd
import re
import math
import locale
from locale import atof

def degToRad(deg):
    return deg * math.pi / 180

def distancia(slat1, slong1, slat2, slong2) -> float:
    raio_terra = 6371
    lat1 = atof(slat1)
    long1 = atof(slong1)
    lat2 = atof(slat2)
    long2 = atof(slong2)
    d_lat = degToRad(lat2 - lat1)
    d_long = degToRad(long2 - long1)

    lat1 = degToRad(lat1)
    lat2 = degToRad(lat2)

    a = math.sin(d_lat/2) * math.sin(d_lat/2) + math.sin(d_long/2) * math.sin(d_long/2) * math.cos(lat1) * math.cos(lat2)
    c = 2*math.atan2(math.sqrt(a), math.sqrt(1-a))

    return raio_terra * c

def getID(pontos_recolha : dict, nome):
    for key in pontos_recolha:
        if pontos_recolha[key][3] == nome:
            return pontos_recolha[key][0]

def match(pontos_recolha : dict, nome):
        for key in pontos_recolha:
            print('nome in match: ' + nome + ' ant in match: ' + pontos_recolha[key][4] + ' | seg in match: ' + pontos_recolha[key][5])
            if pontos_recolha[key][4] == nome or pontos_recolha[key][5] == nome:
                print(pontos_recolha[key][3])
                return pontos_recolha[key][3]

def getLat(pontos_recolha : dict, id_local):
    return pontos_recolha[id_local][1]

def getLong(pontos_recolha : dict, id_local):
    return pontos_recolha[id_local][2]
    
dataframe = pd.read_excel('../data/dataset.xlsx', engine='openpyxl')

knowledgebase = open('base_conhecimento.pl', "w")

knowledgebase.write('% SISTEMAS DE REPRESENTACÃO DO CONHECIMENTO E RACIOCÍNIO\n\n% ------Base de Conhecimento------\n\n% ponto_recolha: Id, Latituide, Longitude, NomeRua, Rua_Anterior, Rua_Seguinte, Direcao -> {V,F}\n\n')

i = 0

pontos_recolha = {}

while i < len(dataframe['OBJECTID']): 

    if "," not in dataframe.iloc[i]['PONTO_RECOLHA_LOCAL']:
        id_local = str(re.sub(':.*', '',  dataframe.iloc[i]['PONTO_RECOLHA_LOCAL']))
        nome_rua = re.sub('\\(.*', '', re.sub('[0-9]+: ', '', dataframe.iloc[i]['PONTO_RECOLHA_LOCAL']))
        rua_anterior = re.sub('-.*', '', re.sub('.*\\): ', '', dataframe.iloc[i]['PONTO_RECOLHA_LOCAL']))
        rua_seguinte = re.sub('\\)', '', re.sub('.*- ', '', dataframe.iloc[i]['PONTO_RECOLHA_LOCAL']))
        latitude = str(dataframe.iloc[i]['Latitude'])
        longitude = str(dataframe.iloc[i]['Longitude'])

        direcao = "Par"

        if "Ambos" in dataframe.iloc[i]['PONTO_RECOLHA_LOCAL']:
            direcao = "Ambos"
        elif "Impar" in dataframe.iloc[i]['PONTO_RECOLHA_LOCAL']:
            direcao = "Impar"

        pontos_recolha[id_local] = [id_local, latitude, longitude, nome_rua, rua_anterior, rua_seguinte, direcao]
        # print(str([id_local, latitude, longitude, nome_rua, rua_anterior, rua_seguinte, direcao]))

    
    else:
        id_local = str(re.sub(':.*', '',  dataframe.iloc[i]['PONTO_RECOLHA_LOCAL']))
        latitude = str(dataframe.iloc[i]['Latitude'])
        longitude = str(dataframe.iloc[i]['Longitude'])
        nome_rua = re.sub(',[a-zA-Z0-9\\-/º]*', '', re.sub('[0-9]*: ', '', dataframe.iloc[i]['PONTO_RECOLHA_LOCAL']))
        print('nome rua unico: ' + nome_rua)
        rua_anterior = match(pontos_recolha, nome_rua)
        rua_seguinte = rua_anterior
        direcao = "Ambos"

        pontos_recolha[id_local] = [id_local, latitude, longitude, nome_rua, rua_anterior, rua_seguinte, direcao]
        # print(str([id_local, latitude, longitude, nome_rua, rua_anterior, rua_seguinte, direcao]))


    i = i + 1

for key,values in pontos_recolha.items():
    knowledgebase.write('ponto_recolha(' + values[0] + ', ' + values[1] + ', ' + values[2] + ', "' + values[3] + '", "' + values[4] + '", "' + values[5] + '", ' + values[6] + ').\n')

knowledgebase.write('\n% aresta: IdOrigem, IdDestino, Distancia -> {V,F}\n\n')

arestas = []
for key,value in pontos_recolha.items():
    id_adj1 = getID(pontos_recolha, value[4])
    id_adj2 = getID(pontos_recolha, value[5])
    lat_p = getLat(pontos_recolha, key)
    long_p = getLong(pontos_recolha, key)

    if value[6] == "Par":
        if id_adj1 != None:
            lat_adj1 = getLat(pontos_recolha, id_adj1)
            long_adj1 = getLong(pontos_recolha, id_adj1)
            dist_adj1 = distancia(lat_p, long_p, lat_adj1, long_adj1)
            arestas.append([id_adj1, key, dist_adj1])
        if id_adj2 != None:
            lat_adj2 = getLat(pontos_recolha, id_adj2)
            long_adj2 = getLong(pontos_recolha, id_adj2)
            dist_adj2 = distancia(lat_P, long_p, lat_adj2, long_adj2)
            arestas.append([id_p, id_adj2, dist_adj2])

    elif value[6] == "Impar":
        if id_adj2 != None:
            lat_adj2 = getLat(pontos_recolha, id_adj2)
            long_adj2 = getLong(pontos_recolha, id_adj2)
            dist_adj2 = distancia(lat_P, long_p, lat_adj2, long_adj2)
            arestas.append([id_adj2, key, dist_adj2])  
        if id_adj1 != None:
            lat_adj1 = getLat(pontos_recolha, id_adj1)
            long_adj1 = getLong(pontos_recolha, id_adj1)
            dist_adj1 = distancia(lat_p, long_p, lat_adj1, long_adj1)
            arestas.append([key, id_adj1, dist_adj1])

    else:
        if id_adj1 != None:
            lat_adj1 = getLat(pontos_recolha, id_adj1)
            long_adj1 = getLong(pontos_recolha, id_adj1)
            dist_adj1 = distancia(lat_p, long_p, lat_adj1, long_adj1)
            arestas.append([id_adj1, key, dist_adj1])
        if id_adj2 != None:
            lat_adj2 = getLat(pontos_recolha, id_adj2)
            long_adj2 = getLong(pontos_recolha, id_adj2)
            dist_adj2 = distancia(lat_P, long_p, lat_adj2, long_adj2)
            arestas.append([key, id_adj2, dist_adj2])
        if id_adj2 != None:
            lat_adj2 = getLat(pontos_recolha, id_adj2)
            long_adj2 = getLong(pontos_recolha, id_adj2)
            dist_adj2 = distancia(lat_P, long_p, lat_adj2, long_adj2)
            arestas.append([id_adj2, key, dist_adj2])  
        if id_adj1 != None: 
            lat_adj1 = getLat(pontos_recolha, id_adj1)
            long_adj1 = getLong(pontos_recolha, id_adj1)
            dist_adj1 = distancia(lat_p, long_p, lat_adj1, long_adj1)
            arestas.append([key, id_adj1, dist_adj1])


for aresta in arestas:
    knowledgebase.write('aresta(' + aresta[0] + ', ' + aresta[1] + ', ' + str(aresta[2]) + ').\n')

knowledgebase.write('\n')

knowledgebase.close()
