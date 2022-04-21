﻿within TransiEnt.Basics.Icons;
package Grid


//________________________________________________________________________________//
// Component of the TransiEnt Library, version: 2.0.1                             //
//                                                                                //
// Licensed by Hamburg University of Technology under the 3-BSD-clause.           //
// Copyright 2021, Hamburg University of Technology.                              //
//________________________________________________________________________________//
//                                                                                //
// TransiEnt.EE, ResiliEntEE, IntegraNet and IntegraNet II are research projects  //
// supported by the German Federal Ministry of Economics and Energy               //
// (FKZ 03ET4003, 03ET4048, 0324027 and 03EI1008).                                //
// The TransiEnt Library research team consists of the following project partners://
// Institute of Engineering Thermodynamics (Hamburg University of Technology),    //
// Institute of Energy Systems (Hamburg University of Technology),                //
// Institute of Electrical Power and Energy Technology                            //
// (Hamburg University of Technology)                                             //
// Fraunhofer Institute for Environmental, Safety, and Energy Technology UMSICHT, //
// Gas- und Wärme-Institut Essen						  //
// and                                                                            //
// XRG Simulation GmbH (Hamburg, Germany).                                        //
//________________________________________________________________________________//






  annotation (Icon(graphics={
    Rectangle(
      lineColor={200,200,200},
      fillColor={248,248,248},
      fillPattern=FillPattern.HorizontalCylinder,
      extent={{-100,-100},{100,100}},
      radius=25.0),
    Rectangle(
      lineColor={128,128,128},
      fillPattern=FillPattern.None,
      extent={{-100,-100},{100,100}},
      radius=25.0),
    Rectangle(
      fillColor={95,95,95},
      fillPattern=FillPattern.Solid,
      extent={{-100,-100},{100,-72}},
      radius=25,
      pattern=LinePattern.None),
    Rectangle(
      extent={{-100,-72},{100,-86}},
      fillColor={0,122,122},
      fillPattern=FillPattern.Solid,
      pattern=LinePattern.None),
    Line(
      points={{-40,68},{-40,-40}},
      color={0,0,0},
      smooth=Smooth.None),
    Line(
      points={{0,68},{0,-40}},
      color={0,0,0},
      smooth=Smooth.None),
    Line(
      points={{42,68},{42,-40}},
      color={0,0,0},
      smooth=Smooth.None),
    Line(
      points={{0,54},{0,-54}},
      color={0,0,0},
      smooth=Smooth.None,
      origin={0,48},
      rotation=90),
    Line(
      points={{0,54},{0,-54}},
      color={0,0,0},
      smooth=Smooth.None,
      origin={0,12},
      rotation=90),
    Line(
      points={{0,54},{0,-54}},
      color={0,0,0},
      smooth=Smooth.None,
      origin={2,-22},
      rotation=90)}), Documentation(info="<html>
<h4><span style=\"color: #008000\">1. Purpose of model</span></h4>
<p>Package created for using the icon</p>
<h4><span style=\"color: #008000\">2. Level of detail, physical effects considered, and physical insight</span></h4>
<p>(Purely technical component without physical modeling.)</p>
<h4><span style=\"color: #008000\">3. Limits of validity </span></h4>
<p>(Purely technical component without physical modeling.)</p>
<h4><span style=\"color: #008000\">4.Interfaces</span></h4>
<p>(no remarks)</p>
<h4><span style=\"color: #008000\">5. Nomenclature</span></h4>
<p>(no elements)</p>
<h4><span style=\"color: #008000\">6. Governing Equations</span></h4>
<p>(no equations)</p>
<h4><span style=\"color: #008000\">7. Remarks for Usage</span></h4>
<p>(no remarks)</p>
<h4><span style=\"color: #008000\">8. Validation</span></h4>
<p>(no validation or testing necessary)</p>
<h4><span style=\"color: #008000\">9. References</span></h4>
<p>(no remarks)</p>
<h4><span style=\"color: #008000\">10. Version History</span></h4>
</html>"));
end Grid;
