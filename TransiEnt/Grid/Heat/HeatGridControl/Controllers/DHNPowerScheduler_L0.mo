﻿within TransiEnt.Grid.Heat.HeatGridControl.Controllers;
model DHNPowerScheduler_L0 "Sample model to calculate amount of power to be generated by large scale CHP plants"




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
 extends TransiEnt.Basics.Icons.LargeController;

  // _____________________________________________
  //
  //             Visible Parameters
  // _____________________________________________

//  parameter Real CoalCost;
  parameter Real MarginalCost_Coal=28;
  parameter Real MarginalCost_Gas=49;

  parameter Real P_max_GuD=127e6;

  // _____________________________________________
  //
  //             Variable Declarations
  // _____________________________________________

   Real pWT_max;
   Real pWT_min;
   Real pWW1_max;
   Real pWW1_min;
   Real pWW2_max;
   Real pWW2_min;

   Real E_KWK;
   Real E_WT_min;
   Real E_WW1_min;
   Real E_WW2_min;

  // _____________________________________________
  //
  //                  Interfaces
  // _____________________________________________

  TransiEnt.Basics.Interfaces.Thermal.HeatFlowRateIn Q_flow_Target_WT "Q_flow_Target_WT: takes the heat flow to be supplied by one of the CHP plants [W]"
    annotation (Placement(transformation(extent={{-142,-2},{-102,38}}), iconTransformation(extent={{-120,40},{-100,60}})));
  TransiEnt.Basics.Interfaces.Thermal.HeatFlowRateIn Q_flow_Target_WW " Q_flow_Target_WW: takes the heat flow to be supplied by one of the CHP plants [W]"
    annotation (Placement(transformation(extent={{-140,-80},{-100,-40}}),
        iconTransformation(extent={{-120,-60},{-100,-40}})));
  TransiEnt.Basics.Interfaces.Electrical.ElectricPowerOut P_out_WT " P_out_WT: delivers the target value of power generation to one of the CHP plants [W]" annotation (Placement(
        transformation(extent={{100,76},{120,96}}), iconTransformation(extent={{100,60},{120,80}})));
  TransiEnt.Basics.Interfaces.Electrical.ElectricPowerOut P_out_WW1 "P_out_WW: delivers the target value of power generation to one of the CHP plants [W]" annotation (Placement(
        transformation(extent={{100,38},{120,58}}), iconTransformation(extent={{100,20},{120,40}})));
  TransiEnt.Basics.Interfaces.Electrical.ElectricPowerOut P_out_WW2 "P_out_WW: delivers the target value of power generation to one of the CHP plants [W]" annotation (Placement(
        transformation(extent={{100,-20},{120,0}}),   iconTransformation(extent={{100,-20},{120,0}})));
  TransiEnt.Basics.Interfaces.Electrical.ElectricPowerOut P_out_total "Output for total power" annotation (Placement(
        transformation(extent={{100,-86},{120,-66}}), iconTransformation(extent={{100,-86},{120,-66}})));
  Modelica.Blocks.Interfaces.RealInput spotPrice " spotPrice: takes the value of the spot price [Eur/MWh]" annotation (Placement(
        transformation(
        extent={{-20,-20},{20,20}},
        rotation=270,
        origin={0,122}),  iconTransformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={0,110})));

 // _____________________________________________
  //
  //           Instances of other Classes
  // _____________________________________________

  HeatFlowDivision schedulingTwoBlocks(HeatFlowCL=Base.DHGHeatFlowDivisionCharacteristicLines.SampleHeatFlowCharacteristicLines2Units()) annotation (Placement(transformation(extent={{-56,-32},{-36,-12}})));
  TransiEnt.Producer.Combined.LargeScaleCHP.Base.PQBoundaries pQDiagram_WT(PQCharacteristics=TransiEnt.Producer.Combined.LargeScaleCHP.Base.Characteristics.PQ_Characteristics_WT()) annotation (Placement(transformation(extent={{-20,60},{0,80}})));
  TransiEnt.Producer.Combined.LargeScaleCHP.Base.PQBoundaries pQDiagram_WW1(PQCharacteristics=TransiEnt.Producer.Combined.LargeScaleCHP.Base.Characteristics.PQ_Characteristics_WW1()) annotation (Placement(transformation(extent={{-22,0},{-2,20}})));
  TransiEnt.Producer.Combined.LargeScaleCHP.Base.PQBoundaries pQDiagram_WW2(PQCharacteristics=TransiEnt.Producer.Combined.LargeScaleCHP.Base.Characteristics.PQ_Characteristics_WW2()) annotation (Placement(transformation(extent={{-20,-80},{0,-60}})));

  Modelica.Blocks.Interfaces.RealOutput GasKW
    annotation (Placement(transformation(extent={{100,-64},{120,-44}}), iconTransformation(extent={{100,-64},{120,-44}})));
equation
  // _____________________________________________
  //
  //           Characteristic Equations
  // _____________________________________________

   pWT_max= pQDiagram_WT.P_max;
   pWT_min= pQDiagram_WT.P_min;
   pWW1_max= pQDiagram_WW1.P_max;
   pWW1_min= pQDiagram_WW1.P_min;
   pWW2_max= pQDiagram_WW2.P_max;
   pWW2_min= pQDiagram_WW2.P_min;

   if spotPrice>MarginalCost_Coal then
   P_out_WT= pWT_max;
   P_out_WW1= pWW1_max;
   P_out_WW2= pWW2_max;

   else

   P_out_WT= pWT_min;
   P_out_WW1= pWW1_min;
   P_out_WW2= pWW2_min;

   end if;

   if spotPrice>MarginalCost_Gas then
   GasKW=P_max_GuD;

   else

   GasKW=0;

   end if;

  P_out_total=P_out_WT+P_out_WW1+P_out_WW2;

   E_KWK=E_WT_min+E_WW1_min+E_WW2_min;
   der(E_WT_min)=pWT_min;
   der(E_WW1_min)=pWW1_min;
   der(E_WW2_min)=pWW2_min;

  // _____________________________________________
  //
  //               Connect Statements
  // _____________________________________________

  connect(Q_flow_Target_WT, pQDiagram_WT.Q_flow) annotation (Line(points={{-122,18},{-72,18},{-72,70},{-22,70}}, color={0,0,127}));
  connect(schedulingTwoBlocks.Q_flow_i[1], pQDiagram_WW1.Q_flow) annotation (Line(points={{-35,-22},{-30,-22},{-30,10},{-24,10}}, color={0,0,127}));
  connect(schedulingTwoBlocks.Q_flow_i[2], pQDiagram_WW2.Q_flow) annotation (Line(points={{-35,-22},{-28,-22},{-28,-70},{-22,-70}}, color={0,0,127}));
  connect(schedulingTwoBlocks.Q_flow_total, Q_flow_Target_WW) annotation (Line(points={{-58,-22},{-84,-22},{-84,-60},{-120,-60}}, color={0,0,127}));
  annotation (Diagram(graphics,
                      coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{100,100}})),           Icon(coordinateSystem(extent={{-100,-100},{100,100}},
                              preserveAspectRatio=false), graphics={
        Text(
          extent={{-34,124},{40,40}},
          lineColor={0,128,0},
          textString="€/MWh"),
        Text(
          extent={{-35,32},{35,-32}},
          lineColor={0,128,0},
          textString="P_el [i]",
          origin={86,7},
          rotation=-90),
        Text(
          extent={{-40.5,42.5},{40.5,-42.5}},
          lineColor={0,128,0},
          origin={-82.5,5.5},
          rotation=90,
          textString="Q_flow [i]"),                                                                             Text(
          extent={{-154,-124},{172,-92}},
          lineColor={0,0,0},
          fillPattern=FillPattern.Sphere,
          fillColor={255,255,0},
          textString="%name")}),
    Documentation(info="<html>
<h4><span style=\"color: #008000\">1. Purpose of model</span></h4>
<p>Calculates amount of power to be generated by the Combined Heat and Power plants based on </p>
<p>* The amount of heating power that they should provide (time series)</p>
<p>* Power price in the spot market (time series)</p>
<h4><span style=\"color: #008000\">2. Level of detail, physical effects considered, and physical insight</span></h4>
<p>PQ Diagrams are used for this</p>
<h4><span style=\"color: #008000\">3. Limits of validity </span></h4>
<h4><span style=\"color: #008000\">4. Interfaces</span></h4>
<p>Inputs:</p>
<p>* Q_flow_Target_WT: takes the heat flow to be supplied by one of the CHP plants [W]</p>
<p>* Q_flow_Target_WW: takes the heat flow to be supplied by one of the CHP plants [W]</p>
<p>* spotPrice: takes the value of the spot price [Eur/MWh]</p>
<p>* P_out_WT: delivers the target value of power generation to one of the CHP plants [W]</p>
<p>*P_out_WW: delivers the target value of power generation to one of the CHP plants [W]</p>
<h4><span style=\"color: #008000\">5. Nomenclature</span></h4>
<p>(no elements)</p>
<h4><span style=\"color: #008000\">6. Governing Equations</span></h4>
<p>PQ-Diagrams for each of the plants</p>
<p>schedulingTwoBlocks component</p>
<p>Calculation of the target power output</p>
<h4><span style=\"color: #008000\">7. Remarks for Usage</span></h4>
<p>(no remarks)</p>
<h4><span style=\"color: #008000\">8. Validation</span></h4>
<p>(no validation or testing necessary)</p>
<h4><span style=\"color: #008000\">9. References</span></h4>
<p>(no remarks)</p>
<h4><span style=\"color: #008000\">10. Version History</span></h4>
<p>Model created by Ricardo Peniche</p>
</html>"));
end DHNPowerScheduler_L0;
