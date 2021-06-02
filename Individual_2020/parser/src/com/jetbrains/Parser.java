package com.jetbrains;

import org.apache.commons.math3.util.Precision;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

//XSSF (XML Spreadsheet Format) − It is used for xlsx file format of MS-Excel.

import java.io.*;
import java.util.*;


class Cidade {
    int IDCidade;
    String nomeCidade;
    float latitude;
    float longitude;
    String responsavelAdministrativo;
    String tipoPoderesAdministrativos;
    ArrayList<Integer> cidadesAdjacentes;
    int patrimonioMundial;
    int castelo;
    int cemMilHabitantes;

    public Cidade(int id) {
        IDCidade = id;
    }


    public static void escreveCabecalho(FileWriter writer) throws IOException {
        writer.write("%SISTEMAS DE REPRESENTAÇÃO  DO CONHECIMENTO E RACIOCINIO \n\n");
        writer.write("%-------------------------------Base de Conhecimento------------------------------ \n");
        writer.write("%-------------------------------------------------------------  \n");
        writer.write("%Cidade: Id,Lat,Long,Designacao,RespAdminist, PoderesAdminist, CidadesAdjac," +
                       "PatrimMundial, Castelos, CemMilHabit -> {V,F} \n\n");
    }

    public void escreveEmFicheiro(FileWriter writer) throws IOException {
        writer.write("cidade(" + IDCidade + "," + latitude + "," + longitude +
                ",'" + nomeCidade + "','" + responsavelAdministrativo + "','" +
                tipoPoderesAdministrativos + "'," + cidadesAdjacentes + "," + patrimonioMundial +
                "," + castelo + "," +  cemMilHabitantes + ").\n");
    }



    public String trataString(String str) {
        String [] orig = {"é", "É", "à", "á", "Á", "ó", "Ó", "í", "Í", "ú", "Ú", "ç", "ã", "õ", "ô"};
        String [] dest = {"e", "E", "a", "a", "A", "o", "O", "i", "I", "u", "U", "c", "a", "o", "o"};

        for (int pos = 0; pos < orig.length; pos++) {
            str = str.replaceAll(orig[pos], dest[pos]);
        }

        return str;
    }



    public void novaColuna(int coluna, String dados) {
        if(!dados.equals("")) {
            switch (coluna) {
                case 0:
                    //está definido no contstruror o id;
                    break;
                case 1:
                    nomeCidade = trataString(dados);
                    break;
                case 2:
                    latitude = Float.parseFloat(dados);
                    break;
                case 3:
                    longitude = Float.parseFloat(dados);
                    break;
                case 4:
                    responsavelAdministrativo = trataString(dados);
                    break;
                case 5:
                    tipoPoderesAdministrativos = trataString(dados);
                    break;
                case 6:
                    patrimonioMundial = Integer.parseInt(dados);
                case 7:
                    castelo = Integer.parseInt(dados);
                case 8:
                    cemMilHabitantes = Integer.parseInt(dados);
            }
        }
    }

    //calcula a distância entre duas cidades com base nas duas coordenadas
    public boolean arcoDistancia(Cidade cidadeOrigem, Cidade cidadeDestino) {

        double x = Math.abs(cidadeDestino.longitude - cidadeOrigem.longitude);
        double y = Math.abs(cidadeDestino.latitude - cidadeOrigem.latitude);

        //prevents over and underflows and returns the square root of the sum of squares of its arguments
        double distanciaEntreCidades = Math.hypot(x,y);

        double distancia = Precision.round(distanciaEntreCidades, 3); //até às centésimas

        if(distancia <= 0.400) {
            return true;
        }

        return false;
    }


    public static void construirAdjacencias(ArrayList<Cidade> cidades){


        for(int origem = 0; origem < cidades.size(); origem++) {

            for(int destino = 0; destino < cidades.size(); destino++) {

                if (cidades.get(origem).IDCidade != cidades.get(destino).IDCidade &&
                        cidades.get(origem).arcoDistancia(cidades.get(origem), cidades.get(destino))) {
                    cidades.get(origem).cidadesAdjacentes.add(cidades.get(destino).IDCidade);
                }
            }
        }
    }

}


class Adjacencia {
    int IDCidadeOrigem;
    int IDCidadeDestino;
    double Distancia;

    public Adjacencia(){
        IDCidadeOrigem = 0;
        IDCidadeDestino = 0;
        Distancia = 0;
    }

    public void adjacencias(Cidade origem, Cidade destino){
        IDCidadeOrigem = origem.IDCidade;
        IDCidadeDestino = destino.IDCidade;

        double x = Math.abs(destino.longitude - origem.longitude);
        double y = Math.abs(destino.latitude - origem.latitude);

        //prevents over and underflows and returns the square root of the sum of squares of its arguments
        double distanciaEntreCidades = Math.hypot(x,y);

        Distancia = Precision.round(distanciaEntreCidades, 3); //até às centésimas
    }


    public static void construirAdjacencias(Cidade origem, ArrayList<Cidade> cidades,
                                            Map<Cidade, ArrayList<Adjacencia>> cidadeAdjacenciaMap) {

        ArrayList<Adjacencia> adjacencias = new ArrayList<Adjacencia>();

        for (int i = 0; i < origem.cidadesAdjacentes.size(); i++) {
            Adjacencia adjacencia = new Adjacencia();
            int destinoId = origem.cidadesAdjacentes.get(i);
            Cidade cidadeDestino = cidades.get(destinoId);
            adjacencia.adjacencias(origem, cidadeDestino);
            adjacencias.add(adjacencia);
        }


        cidadeAdjacenciaMap.put(origem, adjacencias);

    }


    public void escreveAdjacenciasFicheiro(FileWriter writer) throws IOException {
        writer.write("adjacencia(" + IDCidadeOrigem + "," + IDCidadeDestino + "," + Distancia + ").\n");
    }
}




public class Parser {
    static String cidades = "../dados/cidades.xlsx";
    static String ficheiroOutput = "../baseConhecimento.pl";

    

    public static Map<Cidade, ArrayList<Adjacencia>> todasCidades() {

        ArrayList<Cidade> listaCidades = new ArrayList<Cidade>();

        File ficheiro = new File(cidades);   //creating a new file instance
        try {
            FileInputStream f = new FileInputStream(ficheiro);

            //XSSFWorkbook class that is used to represent both high and low level Excel file formats.
            XSSFWorkbook ficheiroExcel = new XSSFWorkbook(f); //Constructs an XSSFWorkbook object from a given file.

            XSSFSheet folha1 = ficheiroExcel.getSheetAt(0); //to retrieve the individual Sheet objects.

            XSSFSheet folha2 = ficheiroExcel.getSheetAt(1);

            Iterator<Row> iteradorLinhaFolha1 = folha1.iterator();

            Iterator<Row> iteradorLinhaFolha2 = folha2.iterator();

            iteradorLinhaFolha1.next(); //não queremos as designações

            iteradorLinhaFolha2.next();

            int id = 0;
            while (iteradorLinhaFolha1.hasNext() && iteradorLinhaFolha2.hasNext()){
                Row linhaSegFolha1 = iteradorLinhaFolha1.next();
                Row linhaSegFolha2 = iteradorLinhaFolha2.next();
                Cidade novaCidade = new Cidade(id);
                id++;
                novaCidade.cidadesAdjacentes = new ArrayList<Integer>();

                int coluna = 0;
                Iterator<Cell> celulaIteradorFolha1 = linhaSegFolha1.cellIterator();
                Iterator<Cell> celulaIteradorFolha2 = linhaSegFolha2.cellIterator();

                while (celulaIteradorFolha1.hasNext()) {
                    Cell celulaFolha1 = celulaIteradorFolha1.next();

                    celulaFolha1.setCellType(CellType.STRING);
                    novaCidade.novaColuna(coluna, celulaFolha1.getStringCellValue());

                    coluna++;
                }
                while (celulaIteradorFolha2.hasNext()) {
                    Cell celulaFolha2 = celulaIteradorFolha2.next();

                    //se for a coluna que tem os id é para ignorar
                    int nColuna = celulaFolha2.getColumnIndex();
                    if (nColuna == 0)
                        celulaFolha2 = celulaIteradorFolha2.next();

                    celulaFolha2.setCellType(CellType.STRING);
                    novaCidade.novaColuna(coluna, celulaFolha2.getStringCellValue());

                    coluna++;
                }

                listaCidades.add(novaCidade);
            }
        } catch (FileNotFoundException e) {
            System.out.println(e);
        }
        catch (IOException e) {
            System.out.println(e);
        }

        Map<Cidade, ArrayList<Adjacencia>> cidadeAdjacenciaMap = new HashMap<Cidade, ArrayList<Adjacencia>>();

        Cidade.construirAdjacencias(listaCidades);

        System.out.println("O numero da listaCidades é " + listaCidades.size());

        for (int origem = 0; origem < listaCidades.size(); origem++)
            Adjacencia.construirAdjacencias(listaCidades.get(origem), listaCidades, cidadeAdjacenciaMap);

        return cidadeAdjacenciaMap;
    }



    public static void escreveCidades(Map<Cidade, ArrayList<Adjacencia>> cidadesAdjacenciaMap){
        try {
            FileWriter writer = new FileWriter(ficheiroOutput);
            Cidade.escreveCabecalho(writer);
            for(Cidade cidade : cidadesAdjacenciaMap.keySet())
                cidade.escreveEmFicheiro(writer);
            writer.close();
            System.out.println("Escreveu cidades no ficheiro baseConhecimento.pl.");

        } catch (IOException e) {
            System.out.println("Erro na escrita das cidades no ficheiro baseConhecimento.pl.");
            e.printStackTrace();
        }
    }


    public static void escreveAdjacencias(Map<Cidade, ArrayList<Adjacencia>> cidadesAdjacenciaMap){
        try {
            FileWriter writer = new FileWriter(ficheiroOutput, true);
            writer.write("\n\n %ADJACENCIAS \n\n");
            writer.write("%Adjacencia: Origem, Destino, Distancia -> {V,F} \n\n");

            for(ArrayList<Adjacencia> lista: cidadesAdjacenciaMap.values())
                for(Adjacencia adjacencia : lista)
                    adjacencia.escreveAdjacenciasFicheiro(writer);
            writer.close();
            System.out.println("Escreveu a adjacencia no ficheiro baseConhecimento.pl.");

        } catch (IOException e) {
            System.out.println("Erro na escrita das adjacencias no ficheiro baseConhecimento.pl.");
            e.printStackTrace();
        }
    }


    public static void main(String[] args) {

        Map<Cidade, ArrayList<Adjacencia>> cidadeAdjacenciaMap = todasCidades();

        escreveCidades(cidadeAdjacenciaMap);

        escreveAdjacencias(cidadeAdjacenciaMap);


        System.out.println("Numero de Cidades : " + cidadeAdjacenciaMap.keySet().size());
        System.out.println("Numero de Adjacencias : " + cidadeAdjacenciaMap.values().size());


    }
}
