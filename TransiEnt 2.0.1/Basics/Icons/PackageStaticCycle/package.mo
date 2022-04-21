﻿within TransiEnt.Basics.Icons;
partial package PackageStaticCycle



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
            {100,100}}), graphics={
                             Rectangle(
          extent={{-98,98},{98,-98}},
          lineColor={0,127,127},
          lineThickness=0.5,
          fillColor={175,175,175},
          fillPattern=FillPattern.Solid),                                    Text(
          extent={{-100,-98},{100,-64}},
          lineColor={62,62,62},
          fillColor={0,134,134},
          fillPattern=FillPattern.Solid,
          textString="%name"),
        Line(
          points={{-72,76},{-72,-58},{76,-58}},
          color={95,95,95},
          smooth=Smooth.None),
        Polygon(
          points={{-72,82},{-74,74},{-70,74},{-72,82}},
          lineColor={95,95,95},
          smooth=Smooth.None,
          fillColor={0,134,134},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{0,4},{-2,-4},{2,-4},{0,4}},
          lineColor={95,95,95},
          smooth=Smooth.None,
          fillColor={0,134,134},
          fillPattern=FillPattern.Solid,
          origin={74,-58},
          rotation=270),
        Line(
          points={{-72,50},{56,50}},
          color={255,0,0}),
        Ellipse(
          extent={{-30,20},{38,-42}},
          lineColor={0,134,134},
          lineThickness=0.5)}), Documentation(info="<html>
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

end PackageStaticCycle;
