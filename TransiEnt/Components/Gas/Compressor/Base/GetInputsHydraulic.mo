﻿within TransiEnt.Components.Gas.Compressor.Base;
model GetInputsHydraulic "Get enabled inputs and parameters of disabled inputs"




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





  extends Modelica.Blocks.Icons.Block;

  Modelica.Blocks.Interfaces.RealInput m_flow_in "Prescribed mass flow rate" annotation (Placement(transformation(extent={{-140,-100},{-100,-60}}, rotation=0)));
  Modelica.Blocks.Interfaces.RealInput V_flow_in "Prescribed volume flow rate" annotation (Placement(transformation(extent={{-140,-60},{-100,-20}},
                                                                                                                                                  rotation=0)));
  Modelica.Blocks.Interfaces.RealInput dp_in "Prescribed pressure increase" annotation (Placement(transformation(extent={{-140,60},{-100,100}}, rotation=0)));
  Modelica.Blocks.Interfaces.RealInput P_shaft_in "Shaft power input" annotation (Placement(transformation(
        extent={{20,20},{-20,-20}},
        rotation=180,
        origin={-120,0})));
  Modelica.Blocks.Interfaces.RealInput P_el_in "Electric power input" annotation (Placement(transformation(
        extent={{20,20},{-20,-20}},
        rotation=180,
        origin={-120,40})));

  annotation (                   Documentation(info="<html>
<h4><span style=\"color: #008000\">1. Purpose of model</span></h4>
<p>This model gets the value of the desired input. It is a modified version of ClaRa.Components.TurboMachines.Compressors.Fundamentals.GetInputsHydraulic in ClaRa 1.5.1: Electric power was added.</p>
<h4><span style=\"color: #008000\">2. Level of detail, physical effects considered, and physical insight</span></h4>
<p>(no remarks) </p>
<h4><span style=\"color: #008000\">3. Limits of validity </span></h4>
<p>(no remarks) </p>
<h4><span style=\"color: #008000\">4. Interfaces</span></h4>
<p>(no remarks) </p>
<h4><span style=\"color: #008000\">5. Nomenclature</span></h4>
<p>(no remarks) </p>
<h4><span style=\"color: #008000\">6. Governing Equations</span></h4>
<p>(no remarks) </p>
<h4><span style=\"color: #008000\">7. Remarks for Usage</span></h4>
<p>(no remarks)</p>
<h4><span style=\"color: #008000\">8. Validation</span></h4>
<p>(no remarks) </p>
<h4><span style=\"color: #008000\">9. References</span></h4>
<p>(no remarks) </p>
<h4><span style=\"color: #008000\">10. Version History</span></h4>
<p>Model created by Carsten Bode (c.bode@tuhh.de) in Nov 2020</p>
</html>"));
end GetInputsHydraulic;
