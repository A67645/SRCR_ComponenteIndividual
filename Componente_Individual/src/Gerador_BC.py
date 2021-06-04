import pandas as pd
import re

dataframe = pd.read_excel('../data/dataset.xlsx', engine='openpyxl')

knowledgebase = open('base_conhecimento.pl', "w")

i = 0

pontos_recolha = {}

while i < len(dataframe['OBJECTID']): 

    id_local = str(re.sub(':.*', '',  dataframe.iloc[i]['PONTO_RECOLHA_LOCAL']))
    nome_rua = re.sub('\\(.*', '', re.sub('[0-9]+: ', '', dataframe.iloc[i]['PONTO_RECOLHA_LOCAL']))
    rua_anterior = re.sub('-.*', '', re.sub('.*\\): ', '', dataframe.iloc[i]['PONTO_RECOLHA_LOCAL']))
    rua_seguinte = re.sub('\\)', '', re.sub('.*- ', '', dataframe.iloc[i]['PONTO_RECOLHA_LOCAL']))
    latitude = str(dataframe.iloc[i]['Latitude'])
    longitude = str(dataframe.iloc[i]['Longitude'])

    ambos = "0"

    if "Ambos" in dataframe.iloc[i]['PONTO_RECOLHA_LOCAL']:
        ambos = "1"

    pontos_recolha[id_local] = [id_local, latitude, longitude, nome_rua, rua_anterior, rua_seguinte, ambos]

    i = i + 1

for key,values in pontos_recolha.items():
    knowledgebase.write('ponto_recolha(' + values[0] + ', ' + values[1] + ', ' + values[2] + ', "' + values[3] + '", "' + values[4] + '", "' + values[5] + '", ' + values[6] + ').\n')

knowledgebase.close()
