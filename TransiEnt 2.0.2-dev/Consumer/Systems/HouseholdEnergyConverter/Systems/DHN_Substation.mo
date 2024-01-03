within TransiEnt.Consumer.Systems.HouseholdEnergyConverter.Systems;
model DHN_Substation "Substation for district hot water"




//________________________________________________________________________________//
// Component of the TransiEnt Library, version: 2.0.2                             //
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
// Gas- und Wärme-Institut Essen                                                  //
// and                                                                            //
// XRG Simulation GmbH (Hamburg, Germany).                                        //
//________________________________________________________________________________//






  // _____________________________________________
  //
  //          Imports and Class Hierarchy
  // _____________________________________________

  extends Base.Systems(
    final DHN=true,
    final el_grid=true,
    final gas_grid=false);

  import TIL = TILMedia.VLEFluidFunctions;
  // _____________________________________________
  //
  //          Parameters
  // _____________________________________________

  parameter SI.MassFlowRate m_flow_min=0.0001 "Minimum massflow rate";
  parameter SI.Temperature T_start=90 + 273.15 "Temperature at start of the simulation" annotation (Dialog(group="Temperature"));
  parameter Real dT=20 "Constant Temperature Difference between supply and return" annotation (Dialog(group="Temperature"));
  parameter Boolean hotwater=true "domestic hot water is covered by the district heating grid";

  // _____________________________________________
  //
  //           Instances of other Classes
  // _____________________________________________

  TransiEnt.Components.Boundaries.Electrical.ApparentPower.ApparentPower apparentPower(useInputConnectorQ=false, useInputConnectorP=true) annotation (Placement(transformation(extent={{-74,-22},{-54,-2}})));

  TransiEnt.Producer.Heat.Heat2Heat.Substation_indirect_noStorage_L1 substation_indirect_noStorage_L1_1(
    T_start=T_start,
    m_flow_min=m_flow_min) annotation (Placement(transformation(extent={{-14,6},{14,26}})));
  Modelica.Blocks.Math.Add add1 if not hotwater             annotation (Placement(transformation(extent={{-8,-8},{8,8}},
        rotation=270,
        origin={-48,46})));
  Modelica.Blocks.Sources.RealExpression No_DHWDemand(y=0) annotation (Placement(transformation(
        extent={{-7,-5},{7,5}},
        rotation=270,
        origin={35,75})));
public
  Modelica.Blocks.Logical.Switch switch1 annotation (Placement(transformation(
        extent={{6,-6},{-6,6}},
        rotation=90,
        origin={22,42})));
  Modelica.Blocks.Sources.BooleanExpression IsHotWaterCovered(y=hotwater) annotation (Placement(transformation(
        extent={{-7,-6},{7,6}},
        rotation=270,
        origin={22,75})));
equation

  connect(apparentPower.epp, epp) annotation (Line(
      points={{-74,-12},{-80,-12},{-80,-98}},
      color={0,127,0},
      thickness=0.5));

  connect(substation_indirect_noStorage_L1_1.waterPortIn, waterPortIn) annotation (Line(
      points={{-6,6},{-6,-84},{-20,-84},{-20,-98}},
      color={175,0,0},
      thickness=0.5));
  connect(substation_indirect_noStorage_L1_1.waterPortOut, waterPortOut) annotation (Line(
      points={{6.1,5.9},{6.1,-84},{20,-84},{20,-98}},
      color={175,0,0},
      thickness=0.5));
  connect(demand.heatingPowerDemand, substation_indirect_noStorage_L1_1.Q_demand_RH) annotation (Line(
      points={{0,100.48},{0,30},{-11,30},{-11,25}},
      color={175,0,0},
      pattern=LinePattern.Dash));
  connect(demand.hotWaterPowerDemand, switch1.u1) annotation (Line(
      points={{-4.8,100.48},{-4.8,49.2},{17.2,49.2}},
      color={102,44,145},
      pattern=LinePattern.Dash));
  connect(switch1.y, substation_indirect_noStorage_L1_1.Q_demand_DHW) annotation (Line(points={{22,35.4},{22,30},{11,30},{11,25}}, color={0,0,127}));
  connect(IsHotWaterCovered.y, switch1.u2) annotation (Line(points={{22,67.3},{22,49.2}}, color={255,0,255}));
  connect(switch1.u3, No_DHWDemand.y) annotation (Line(points={{26.8,49.2},{26.8,62},{35,62},{35,67.3}}, color={0,0,127}));

  if not hotwater then
     connect(demand.hotWaterPowerDemand, add1.u1) annotation (Line(
      points={{-4.8,100.48},{-4.8,60},{-43.2,60},{-43.2,55.6}},
      color={102,44,145},
      pattern=LinePattern.Dash));
     connect(add1.u2, demand.electricPowerDemand) annotation (Line(points={{-52.8,55.6},{-52.8,82},{4.68,82},{4.68,100.48}}, color={0,0,127}));
     connect(apparentPower.P_el_set, add1.y) annotation (Line(points={{-70,0},{-70,32},{-48,32},{-48,37.2}}, color={0,127,127}));
  else
    connect(demand.electricPowerDemand, apparentPower.P_el_set) annotation (Line(
      points={{4.68,100.48},{4.68,82},{-70,82},{-70,0}},
      color={102,44,145},
      pattern=LinePattern.Dash), Text(
      string="%first",
      index=-1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  end if;


  annotation (Icon(graphics={
        Ellipse(
          lineColor={0,125,125},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          extent={{-100,102},{100,-98}}),
        Rectangle(
          extent={{-28,4},{24,-68}},
          lineColor={127,0,0},
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-28,-68},{-28,4},{24,4},{-28,-68}},
          lineColor={127,0,0},
          fillColor={255,0,0},
          fillPattern=FillPattern.Solid),
        Line(points={{0,4},{0,58},{28,58}}, color={255,0,0}),
        Line(points={{24,-32},{72,-32},{72,58},{62,58},{58,58}}, color={0,0,255}),
        Ellipse(extent={{28,70},{58,42}}, lineColor={127,0,0}),
        Line(points={{-26,-32},{-54,-32},{-54,-78}}, color={255,0,0}),
        Line(points={{2,-80},{2,-68},{2,-96},{2,-96}}, color={255,0,0})}), Documentation(info="<html>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">1. Purpose of model</span></b></p>
<p>Model of a DHN substation to be used in the energyConverter.</p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">2. Level of detail, physical effects considered, and physical insight</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(Purely technical component without physical modeling.)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">3. Limits of validity </span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(Purely technical component without physical modeling.)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">4. Interfaces</span></b></p>
<p>TransiEnt.Basics.Interfaces.Combined.HouseholdDemandIn <b>demand</b></p>
<p>TransiEnt.Basics.Interfaces.Thermal.FluidPortIn <b>waterPortIn</b></p>
<p>TransiEnt.Basics.Interfaces.Thermal.FluidPortOut <b>waterPortOut - connection to district heating grid</b></p><p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">5. Nomenclature</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">6. Governing Equations</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">7. Remarks for Usage</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">8. Validation</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">9. References</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">10. Version History</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">Model created by Anne Hagemeier, Fraunhofer UMSICHT in 2017</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">Modification by Philipp Huismann, Gas- und W&auml;rme-Institut e.V. in 2020</span></p>
</html>"));
end DHN_Substation;
