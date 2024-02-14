﻿within TransiEnt.Producer.Gas.Electrolyzer.Base;
model ElectrolyzerDynamics2ndOrder "2nd order electrolyzer dynamics"



//________________________________________________________________________________//
// Component of the TransiEnt Library, version: 2.0.3                             //
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
// Gas- und WÃ¤rme-Institut Essen						  //
// and                                                                            //
// XRG Simulation GmbH (Hamburg, Germany).                                        //
//________________________________________________________________________________//





  // _____________________________________________
  //
  //          Imports and Class Hierarchy
  // _____________________________________________

  extends TransiEnt.Producer.Gas.Electrolyzer.Base.PartialElectrolyzerDynamics;

  // _____________________________________________
  //
  //        Constants and Hidden Parameters
  // _____________________________________________

  // _____________________________________________
  //
  //              Visible Parameters
  // _____________________________________________

  parameter Real omega_n = 17 "Sets the natural frequency of the electrolyser";
  parameter Real zeta = 0.7 "Set the damping ratio of the electrolyser";

  // _____________________________________________
  //
  //              Variables
  // _____________________________________________

protected
  Real x1(final start=0);
  Real x2(final start=0);

  // _____________________________________________
  //
  //                Interfaces
  // _____________________________________________

equation
  //Equations for Ely 2nd Order
  der(x1) = x2;
  der(x2) = - 2 * zeta * omega_n  * x2 - omega_n^2 * x1 + omega_n^2 * P_el * eta;
  H_flow_H2 = x1;

  annotation (
  defaultConnectionStructurallyInconsistent=true,Diagram(graphics,
                                                         coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}})), Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}}), graphics={Rectangle(
          extent={{-80,40},{80,-40}},
          lineColor={255,255,255},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid), Line(
          points={{-74,-42},{-72,-18},{-66,10},{-56,52},{-32,60},{6,36},{58,42},{82,42}},
          color={255,0,0},
          smooth=Smooth.Bezier)}),
          Documentation(info="<html>
<h4><span style=\"color: #008000\">1. Purpose of model</span></h4>
<p>This is a model for electrolyzer dynamics with second order behavior. </p>
<h4><span style=\"color: #008000\">2. Level of detail, physical effects considered, and physical insight</span></h4>
<p>(no remarks) </p>
<h4><span style=\"color: #008000\">3. Limits of validity </span></h4>
<p>(no remarks) </p>
<h4><span style=\"color: #008000\">4. Interfaces</span></h4>
<p>(no remarks) </p>
<h4><span style=\"color: #008000\">5. Nomenclature</span></h4>
<p>(no elements)</p>
<h4><span style=\"color: #008000\">6. Governing Equations</span></h4>
<p>Hydrogen enthalpy flow and electric power are connected by two first order differential equations. </p>
<h4><span style=\"color: #008000\">7. Remarks for Usage</span></h4>
<p>(no remarks) </p>
<h4><span style=\"color: #008000\">8. Validation</span></h4>
<p>(no remarks) </p>
<h4><span style=\"color: #008000\">9. References</span></h4>
<p>(no remarks) </p>
<h4><span style=\"color: #008000\">10. Version History</span></h4>
<p>Created by Patrick Göttsch (patrick.goettsch@tuhh.de) in April 2014</p>
<p>Edited by Tom Lindemann (tom.lindemann@tuhh.de) in Dec 2015</p>
<p>Edited by Lisa Andresen (andresen@tuhh.de) in May 2016</p>
<p>Edited by Carsten Bode (c.bode@tuhh.de) in March 2017</p>
</html>"));
end ElectrolyzerDynamics2ndOrder;
