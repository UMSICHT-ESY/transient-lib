within TransiEnt.Producer.Heat.Power2Heat.Heatpump.Controller;
model ControlHeatpump_14aEnWG_Direktansteuerung "Operation preferably when excess PV energy available, if bivalent mode selected, heater will switch on additionally to heatpump"

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

  extends TransiEnt.Producer.Heat.Power2Heat.Heatpump.Controller.Base.Controller_PV;
  extends TransiEnt.Basics.Icons.Controller;

   //___________________________________________________________________________
   //
   //                      Parameters
   //___________________________________________________________________________

  input Modelica.Units.SI.Temperature TLow_HP=T_set - 0.7*Delta_T_db "Temperature limit to switch on the heat pump in case of excess PV energy" annotation (Dialog(group="Temperature limits"));
  input Modelica.Units.SI.Temperature THigh_HP=T_set + Delta_T_db "Temperature limit to switch off the heat pump in case of excess PV energy" annotation (Dialog(group="Temperature limits"));
  input Modelica.Units.SI.Temperature THigh2_HP=T_set + Delta_T_db/2 "Temperature limit to switch off the heat pump in case of no excess PV energy" annotation (Dialog(group="Temperature limits"));
  input Modelica.Units.SI.Temperature TLow2_HP=T_set - Delta_T_db/2 "Temperature limit to switch on the heat pump in case of no excess PV energy" annotation (Dialog(group="Temperature limits"));

  input Modelica.Units.SI.Temperature TLow_Heater=T_set - 1.2*Delta_T_db "Temperature limit to switch on the heater" annotation (Dialog(group="Temperature limits"));
  input Modelica.Units.SI.Temperature THigh_Heater=T_set "Temperature limit to switch off the heater" annotation (Dialog(group="Temperature limits"));

  parameter Real SoCLow_HP=0.5 "SOC limit to switch off the heat pump" annotation (Dialog(group="SoC limits"));
  parameter Real SoCHigh_HP=1  "SOC limit to switch on the heat pump" annotation (Dialog(group="SoC limits"));

  parameter Real SoCHigh2_HP=0.8 "SOC limit to switch off the heat pump in case of no excess PV energy" annotation (Dialog(group="SoC limits"));
  parameter Real SoCLow2_HP=0.5  "SOC limit to switch on the heat pump in the of no excess PV energy" annotation (Dialog(group="SoC limits"));

  parameter Real SoCLow_Heater=0.25 "SOC limit to switch on the heater" annotation (Dialog(group="SoC limits"));
  parameter Real SoCHigh_Heater=0.6 "SOC limit to switch off the heater" annotation (Dialog(group="SoC limits"));
  parameter Real SoCSet_HP=0.7 annotation (Dialog(group="SoC limits"));

  parameter Real Threshold=1000 "Excess PV power to start heat pump operation" annotation (Dialog(group="Control parameters"));

  parameter Real summer_start=121 "Day of the year for the start of summer operation" annotation (Dialog(group="Control parameters"));
  parameter Real winter_start=274 "Day of the year for the end of summer operation" annotation (Dialog(group="Control parameters"));

  parameter Modelica.Units.SI.Power P_elHeater=5000 "Nominal electrical power of the electrical heater";

   //___________________________________________________________________________
   //
   //                      Variables
   //___________________________________________________________________________

    Real uHigh_HP;
    Real uLow_HP;
    Real uHigh2_HP;
    Real uLow2_HP;
    Real uHigh_Heater;
    Real uLow_Heater;
    Real uSet_HP;

  // _____________________________________________
  //
  //           Instances of other Classes
  // _____________________________________________

  Modelica.Blocks.Sources.RealExpression uHigh3(y=uHigh_Heater)  annotation (Placement(transformation(extent={{-62,-80},{-46,-66}})));
  Modelica.Blocks.Sources.RealExpression uLow3(y=uLow_Heater) annotation (Placement(transformation(extent={{-58,-96},{-44,-84}})));
  TransiEnt.Basics.Blocks.Hysteresis_inputVariable hysteresis_heater annotation (Placement(transformation(extent={{-32,-90},{-18,-76}})));
  Modelica.Blocks.Logical.Not Not1 annotation (Placement(transformation(extent={{-12,-88},{-2,-78}})));
  Modelica.Blocks.Sources.RealExpression zero1(y=0) annotation (Placement(transformation(extent={{24,-78},{40,-62}})));
  Modelica.Blocks.Sources.RealExpression P_Heater(y=P_elHeater) annotation (Placement(transformation(extent={{-8,-9},{8,9}},
        rotation=90,
        origin={-298,-33})));
  Modelica.Blocks.Logical.Switch switch2 annotation (Placement(transformation(
        extent={{8,-8},{-8,8}},
        rotation=180,
        origin={68,-82})));

  Modelica.Blocks.Continuous.FirstOrder firstOrder1(T=1) if
                                                           Modulating
    annotation (Placement(transformation(extent={{84,-74},{94,-64}})));
  Modelica.Blocks.Math.Product product1 annotation (Placement(transformation(extent={{-330,50},{-310,70}})));
  Modelica.Blocks.Nonlinear.VariableLimiter limiter_HP annotation (Placement(transformation(extent={{-290,42},{-270,62}})));
  Modelica.Blocks.Sources.RealExpression Untergrenze(y=0) if   not Modulating annotation (Placement(transformation(extent={{-330,18},{-314,34}})));
  Modelica.Blocks.Math.Feedback feedback annotation (Placement(transformation(extent={{-320,-12},{-300,8}})));
  Modelica.Blocks.Math.Division division annotation (Placement(transformation(extent={{-336,-46},{-316,-26}})));
  Modelica.Blocks.Math.Min min_elBoiler annotation (Placement(transformation(extent={{-290,-18},{-270,2}})));
  Modelica.Blocks.Math.Max max1 annotation (Placement(transformation(extent={{-380,84},{-360,104}})));
  Modelica.Blocks.Sources.RealExpression Mindestleistung(y=4200) if
                                                               not Modulating annotation (Placement(transformation(extent={{-410,72},{-394,88}})));
  Modelica.Blocks.Interfaces.RealInput COP annotation (Placement(transformation(extent={{-430,34},{-390,74}})));
  Modelica.Blocks.Interfaces.RealInput P_SVE annotation (Placement(transformation(extent={{-430,80},{-390,120}})));
  Modelica.Blocks.Interfaces.RealOutput P_EV annotation (Placement(transformation(extent={{96,-130},{116,-110}})));
  TransiEnt.Basics.Blocks.FilterPosNeg Filter annotation (Placement(transformation(extent={{-374,44},{-354,64}})));
  Modelica.Blocks.Sources.RealExpression Q_flow1(y=Q_flow_n) if
                                                               not Modulating annotation (Placement(transformation(extent={{-8,-8},{8,8}},
        rotation=90,
        origin={-60,-16})));
  Modelica.Blocks.Continuous.LimPID Regler(
    controllerType=Modelica.Blocks.Types.SimpleController.PI,
    k=0.111,
    Ti=3600,
    yMax=1,
    yMin=0,
    withFeedForward=false)
            annotation (Placement(transformation(extent={{-82,10},{-62,30}})));
  Modelica.Blocks.Math.Product product2 annotation (Placement(transformation(extent={{-54,4},{-34,24}})));
  Modelica.Blocks.Continuous.FirstOrder firstOrder2(T=900)
                                                          annotation (Placement(transformation(extent={{-28,4},{-8,24}})));
  Modelica.Blocks.Sources.RealExpression uHigh1(y=20)            annotation (Placement(transformation(extent={{-8,-7},{8,7}},
        rotation=270,
        origin={52,27})));
  Modelica.Blocks.Sources.RealExpression uLow1(y=0)           annotation (Placement(transformation(extent={{-7,-6},{7,6}},
        rotation=90,
        origin={53,-14})));
  TransiEnt.Basics.Blocks.Hysteresis_inputVariable hysteresis_heater1
                                                                     annotation (Placement(transformation(extent={{56,-6},{70,8}})));
  Modelica.Blocks.Sources.RealExpression zero2(y=0) annotation (Placement(transformation(extent={{-8,-8},{8,8}},
        rotation=270,
        origin={74,26})));
  Modelica.Blocks.Logical.Switch switch22 annotation (Placement(transformation(
        extent={{8,-8},{-8,8}},
        rotation=180,
        origin={86,0})));
  Modelica.Blocks.Math.Division division1
                                         annotation (Placement(transformation(extent={{0,-2},{20,18}})));
  Modelica.Blocks.Math.Product product3 annotation (Placement(transformation(extent={{28,-8},{48,12}})));
  Modelica.Blocks.Sources.RealExpression uHigh5(y=100)           annotation (Placement(transformation(extent={{-8,-7},{8,7}},
        rotation=90,
        origin={20,-15})));
equation
  // ___________________________________________________________________________
  //
  //            Characteristic equations
  // ___________________________________________________________________________

  uSet_HP=if control_SoC then SoCSet_HP else T_set;

  uHigh_HP=if control_SoC then SoCHigh_HP else THigh_HP;
  uLow_HP=if control_SoC then SoCLow_HP else TLow_HP;
  uHigh2_HP=if control_SoC then SoCHigh2_HP else THigh2_HP;
  uLow2_HP=if control_SoC then SoCLow2_HP else TLow2_HP;
  uHigh_Heater=if control_SoC then SoCHigh_Heater else THigh_Heater;
  uLow_Heater=if control_SoC then SoCLow_Heater else TLow_Heater;

  // _____________________________________________
  //
  //               Connect Statements
  // _____________________________________________

  if not Modulating then
    connect(switch2.y, P_set_electricHeater);
  end if;

  connect(hysteresis_heater.u, SoC) annotation (Line(points={{-32.7,-83},{-90,-83},{-90,-20},{-102,-20}},           color={0,0,127}));
  connect(zero1.y,switch2. u3) annotation (Line(points={{40.8,-70},{45.45,-70},{45.45,-75.6},{58.4,-75.6}}, color={0,0,127}));
  connect(uLow3.y, hysteresis_heater.uLow) annotation (Line(points={{-43.3,-90},{-38,-90},{-38,-88.6},{-32.7,-88.6}}, color={0,0,127}));
  connect(uHigh3.y,hysteresis_heater. uHigh) annotation (Line(points={{-45.2,-73},{-38,-73},{-38,-77.4},{-32.42,-77.4}},
                                                                                                                       color={0,0,127}));
  connect(Not1.y,switch2. u2) annotation (Line(points={{-1.5,-83},{-1.5,-82},{58.4,-82}},
                                                                              color={255,0,255}));
  connect(hysteresis_heater.y, Not1.u) annotation (Line(points={{-17.3,-83},{-13,-83}},            color={255,0,255}));
  connect(T, hysteresis_heater.u) annotation (Line(points={{-102,20},{-92,20},{-92,18},{-90,18},{-90,-83},{-32.7,-83}}, color={0,0,127}));
  if not MinTimes or Modulating then
  end if;
  connect(firstOrder1.y, P_set_electricHeater)
    annotation (Line(points={{94.5,-69},{109,-69}}, color={0,0,127}));
  connect(switch2.y, firstOrder1.u) annotation (Line(points={{76.8,-82},{80,-82},
          {80,-69},{83,-69}}, color={0,0,127}));
  connect(Untergrenze.y,limiter_HP. limit2) annotation (Line(points={{-313.2,26},{-298,26},{-298,44},{-292,44}},     color={0,0,127}));
  connect(feedback.y,min_elBoiler. u1) annotation (Line(points={{-301,-2},{-292,-2}},   color={0,0,127}));
  connect(division.u2,COP)  annotation (Line(points={{-338,-42},{-380,-42},{-380,54},{-410,54}},                         color={0,0,127}));
  connect(P_SVE,max1. u1) annotation (Line(points={{-410,100},{-382,100}},         color={0,0,127}));
  connect(Mindestleistung.y,max1. u2) annotation (Line(points={{-393.2,80},{-388,80},{-388,88},{-382,88}}, color={0,0,127}));
  connect(max1.y,product1. u1) annotation (Line(points={{-359,94},{-350,94},{-350,66},{-332,66}},                     color={0,0,127}));
  connect(feedback.u1,product1. u1) annotation (Line(points={{-318,-2},{-350,-2},{-350,66},{-332,66}},
                                                                                              color={0,0,127}));
  connect(product1.y,limiter_HP. limit1) annotation (Line(points={{-309,60},{-292,60}},                         color={0,0,127}));
  connect(division.y,feedback. u2) annotation (Line(points={{-315,-36},{-310,-36},{-310,-10}},    color={0,0,127}));
  connect(P_Heater.y, min_elBoiler.u2) annotation (Line(points={{-298,-24.2},{-298,-14},{-292,-14}}, color={0,0,127}));
  connect(min_elBoiler.y, switch2.u1) annotation (Line(points={{-269,-8},{-120,-8},{-120,-106},{46,-106},{46,-88.4},{58.4,-88.4}}, color={0,0,127}));
  connect(P_EV, P_EV) annotation (Line(points={{106,-120},{106,-120}}, color={0,0,127}));
  connect(P_EV, product1.u1) annotation (Line(points={{106,-120},{-160,-120},{-160,-60},{-350,-60},{-350,66},{-332,66}}, color={0,0,127}));
  connect(Filter.y, product1.u2) annotation (Line(points={{-353,54},{-332,54}}, color={0,0,127}));
  connect(Filter.u, COP) annotation (Line(points={{-376,54},{-410,54}}, color={0,0,127}));
  connect(product2.y, firstOrder2.u) annotation (Line(points={{-33,14},{-30,14}}, color={0,0,127}));
  connect(uHigh1.y,hysteresis_heater1. uHigh) annotation (Line(points={{52,18.2},{52,6},{54,6},{54,6.6},{55.58,6.6}}, color={0,0,127}));
  connect(hysteresis_heater1.y,switch22. u2) annotation (Line(points={{70.7,1},{70.7,0},{76.4,0}},                   color={255,0,255}));
  connect(division1.y, product3.u1) annotation (Line(points={{21,8},{26,8}}, color={0,0,127}));
  connect(product3.y,hysteresis_heater1. u) annotation (Line(points={{49,2},{55.3,1}}, color={0,0,127}));
  connect(uHigh5.y,product3. u2) annotation (Line(points={{20,-6.2},{20,-4},{26,-4}}, color={0,0,127}));
  connect(division1.u2, Q_flow1.y) annotation (Line(points={{-2,2},{-2,-4},{-60,-4},{-60,-7.2}}, color={0,0,127}));
  connect(firstOrder2.y, division1.u1) annotation (Line(points={{-7,14},{-2,14}}, color={0,0,127}));
  connect(zero2.y,switch22. u3) annotation (Line(points={{74,17.2},{74,6.4},{76.4,6.4}}, color={0,0,127}));
  connect(uLow1.y,hysteresis_heater1. uLow) annotation (Line(points={{53,-6.3},{54,-6.3},{54,-4.6},{55.3,-4.6}}, color={0,0,127}));
  connect(Regler.y,product2. u1) annotation (Line(points={{-61,20},{-56,20}}, color={0,0,127}));
  connect(Q_flow1.y, product2.u2) annotation (Line(points={{-60,-7.2},{-60,8},{-56,8}}, color={0,0,127}));
  connect(switch22.y, Q_flow_set_HP) annotation (Line(points={{94.8,-3.33067e-16},{108,0}}, color={0,0,127}));
  connect(T_set, Regler.u_s) annotation (Line(points={{-102,46},{-84,46},{-84,20}}, color={0,0,127}));
  connect(T, Regler.u_m) annotation (Line(points={{-102,20},{-88,20},{-88,4},{-72,4},{-72,8}}, color={0,0,127}));
  connect(limiter_HP.u, firstOrder2.u) annotation (Line(points={{-292,52},{-296,52},{-296,80},{-30,80},{-30,14}}, color={0,0,127}));
  connect(limiter_HP.y, switch22.u1) annotation (Line(points={{-269,52},{-114,52},{-114,-40},{76.4,-40},{76.4,-6.4}}, color={0,0,127}));
  connect(division.u1, switch22.u1) annotation (Line(points={{-338,-30},{-342,-30},{-342,16},{-258,16},{-258,52},{-114,52},{-114,-40},{76.4,-40},{76.4,-6.4}}, color={0,0,127}));
  annotation (Diagram(coordinateSystem(extent={{-100,-140},{100,120}}), graphics={
        Rectangle(
          extent={{-64,-66},{0,-94}},
          lineColor={0,0,0},
          pattern=LinePattern.Dash),
        Text(
          extent={{-70,-62},{0,-64}},
          lineColor={0,0,0},
          pattern=LinePattern.Dash,
          fontSize=8,
          textString="Threshold for electric heater"),
        Text(
          extent={{-248,0},{-232,-6}},
          textColor={28,108,200},
          textString="P_elBoiler"),
        Text(
          extent={{-248,-52},{-234,-56}},
          textColor={28,108,200},
          textString="P_EV"),
        Text(
          extent={{-250,62},{-228,52}},
          textColor={28,108,200},
          textString="Q_flow_set_HP")}),                                 Icon(
        coordinateSystem(extent={{-100,-140},{100,120}})),
    Documentation(info="<html>
<p><b><span style=\"color: #008000;\">1. Purpose of model</span></b></p>
<p>Controller model to set electric input power for heat pump and electric heater as well as heat pump temperature according to storage tank level or storage tank temperature as well as PV power. Heatpump will switch on preferably when there is excess PV power, but will operate nonetheless if storage tank temperature drops too low.</p>
<p>For bivalent operation, electric heater produces heat with constant power and operates additionally to heatpump if minimum temperatur cannot be achieved with heatpump alone.</p>
<p><b><span style=\"color: #008000;\">2. Level of detail, physical effects considered, and physical insight</span></b></p>
<p>(Purely technical component without physical modeling.)</p>
<p><b><span style=\"color: #008000;\">3. Limits of validity </span></b></p>
<p>(Purely technical component without physical modeling.)</p>
<p><b><span style=\"color: #008000;\">4. Interfaces</span></b></p>
<p>(no remarks)</p>
<p><b><span style=\"color: #008000;\">5. Nomenclature</span></b></p>
<p>(no elements)</p>
<p><b><span style=\"color: #008000;\">6. Governing Equations</span></b></p>
<p>(no equations)</p>
<p><b><span style=\"color: #008000;\">7. Remarks for Usage</span></b></p>
<p>(no remarks)</p>
<p><b><span style=\"color: #008000;\">8. Validation</span></b></p>
<p>(no validation or testing necessary)</p>
<p><b><span style=\"color: #008000;\">9. References</span></b></p>
<p>(no remarks)</p>
<p><b><span style=\"color: #008000;\">10. Version History</span></b></p>
<p>Created by Anne Hagemeier (anne.hagemeier@umsicht.fraunhofer.de), June 2018</p>
</html>"));
end ControlHeatpump_14aEnWG_Direktansteuerung;
