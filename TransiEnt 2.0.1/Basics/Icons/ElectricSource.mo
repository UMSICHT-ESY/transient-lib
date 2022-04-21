﻿within TransiEnt.Basics.Icons;
partial model ElectricSource "Icon for runnable examples"


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





  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},
            {100,100}}), graphics={Ellipse(
          lineColor={0,125,125},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          extent={{-100,-100},{100,100}}),Rectangle(
          extent={{30,3},{80,-3}},
          lineColor={0,134,134},
          fillColor={0,134,134},
          fillPattern=FillPattern.Solid),Polygon(
          points={{80,10},{80,-10},{100,0},{80,10}},
          lineColor={0,134,134},
          fillColor={0,134,134},
          fillPattern=FillPattern.Solid),Rectangle(
          extent={{-25,3},{25,-3}},
          lineColor={0,134,134},
          fillColor={0,134,134},
          fillPattern=FillPattern.Solid,
          origin={0,-55},
          rotation=270),Polygon(
          points={{-10,10},{-10,-10},{10,0},{-10,10}},
          lineColor={0,134,134},
          fillColor={0,134,134},
          fillPattern=FillPattern.Solid,
          origin={0,-90},
          rotation=270),Rectangle(
          extent={{-25,3},{25,-3}},
          lineColor={0,134,134},
          fillColor={0,134,134},
          fillPattern=FillPattern.Solid,
          origin={-55,0},
          rotation=180),Polygon(
          points={{-10,10},{-10,-10},{10,0},{-10,10}},
          lineColor={0,134,134},
          fillColor={0,134,134},
          fillPattern=FillPattern.Solid,
          origin={-90,0},
          rotation=180),Polygon(
          points={{-10,10},{-10,-10},{10,0},{-10,10}},
          lineColor={0,134,134},
          fillColor={0,134,134},
          fillPattern=FillPattern.Solid,
          origin={0,90},
          rotation=90),Rectangle(
          extent={{-25,3},{25,-3}},
          lineColor={0,134,134},
          fillColor={0,134,134},
          fillPattern=FillPattern.Solid,
          origin={0,55},
          rotation=90),
        Text(
          extent={{-146,-97},{154,-137}},
          lineColor={0,134,134},
          textString="%name")}),
                          Documentation(info="<html>
<h4><span style=\"color: #008000\">1. Purpose of model</span></h4>
<p>Model created for using the icon</p>
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
end ElectricSource;
