package io.snappydata.hydra.udfs;

import org.apache.spark.sql.api.java.UDF15;
import java.util.ArrayList;
import java.util.Collections;

public class JavaUDF15 implements UDF15<Double,Double,Double,Double,Double,Double,Double,Double,Double,Double,Double,Double,Double,Double,Double,Double> {
    public Double call(Double d1, Double d2, Double d3, Double d4, Double d5, Double d6, Double d7, Double d8, Double d9, Double d10, Double d11, Double d12, Double d13, Double d14, Double d15) throws Exception {
        ArrayList<Double> al = new ArrayList<Double>();
        al.add(d1);
        al.add(d2);
        al.add(d3);
        al.add(d4);
        al.add(d5);
        al.add(d6);
        al.add(d7);
        al.add(d8);
        al.add(d9);
        al.add(d10);
        al.add(d11);
        al.add(d12);
        al.add(d13);
        al.add(d14);
        al.add(d15);

        Double d = Collections.max(al);

        return d;
    }
}