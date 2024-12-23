within TransiEnt.Producer.Heat.Power2Heat.Heatpump.Controller;
model Control_Heat_HotWater
  "Operation preferably when excess PV energy available, if bivalent mode selected, heater will switch on additionally to heatpump"

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
// Gas- und WÃ¤rme-Institut Essen                                                  //
// and                                                                            //
// XRG Simulation GmbH (Hamburg, Germany).                                        //
//________________________________________________________________________________//

  // _____________________________________________
  //
  //          Imports and Class Hierarchy
  // _____________________________________________

  extends
    TransiEnt.Producer.Heat.Power2Heat.Heatpump.Controller.Base.Controller_PV;
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

  parameter Real k=0.1 "PI controller gain" annotation (Dialog(group="PI Controller"));
  parameter Modelica.Units.SI.Time T_i=180 "PI controller time constant" annotation (Dialog(group="PI Controller"));
  parameter Modelica.Units.SI.HeatFlowRate Q_flow_n=3.5e3 "Nominal heat flow of heat pump at nominal conditions according to EN14511 (7/35)" annotation (Dialog(group="Heat pump parameters"));
  parameter SI.Power COP_n=3.5 "Coefficient of performance at nominal conditions according to EN14511 (7/35)" annotation (Dialog(group="Heatpump"));
  parameter Modelica.Units.SI.HeatFlowRate P_el_max=5.0e3 "Maximal electric Power of heat pump at 7°C/55°C" annotation (Dialog(group="Heatpump"));


  Modelica.Units.SI.Power P_el_n=P_el_max - max(0,( 273.15 + 55 - T_set) / (55 - 35) * (P_el_max - Q_flow_n/COP_n));
  //parameter Modelica.Units.SI.Power P_el_n=Q_flow_n/COP_n "Nominal electrical power of the heatpump";
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

  Modelica.Blocks.Sources.RealExpression uLow3(y=Delta_T_db)  annotation (Placement(transformation(extent={{-44,-98},
            {-30,-86}})));
  TransiEnt.Basics.Blocks.Hysteresis_inputVariable hysteresis_heater annotation (Placement(transformation(extent={{-10,-90},
            {4,-76}})));
  Modelica.Blocks.Logical.Not Not1 annotation (Placement(transformation(extent={{8,-88},
            {18,-78}})));
  Modelica.Blocks.Sources.RealExpression zero1(y=0) annotation (Placement(transformation(extent={{42,-90},
            {58,-74}})));
  Modelica.Blocks.Sources.RealExpression P_Heater(y=P_elHeater) annotation (Placement(transformation(extent={{-8,-9},{8,9}},
        rotation=0,
        origin={-24,-133})));
  Modelica.Blocks.Logical.Switch switch2 annotation (Placement(transformation(
        extent={{8,-8},{-8,8}},
        rotation=180,
        origin={70,-102})));

  Modelica.Blocks.Continuous.FirstOrder firstOrder1(T=1) if
                                                           Modulating
    annotation (Placement(transformation(extent={{84,-74},{94,-64}})));
  Modelica.Blocks.Math.Product product1 annotation (Placement(transformation(extent={{8,62},{
            28,82}})));
  Modelica.Blocks.Nonlinear.VariableLimiter limiter_HP annotation (Placement(transformation(extent={{24,-16},
            {44,4}})));
  Modelica.Blocks.Math.Feedback difference
    annotation (Placement(transformation(extent={{-30,-118},{-10,-98}})));
  Modelica.Blocks.Math.Division division annotation (Placement(transformation(extent={{-60,
            -134},{-40,-114}})));
  Modelica.Blocks.Interfaces.RealInput COP annotation (Placement(transformation(extent={{-122,
            -70},{-82,-30}})));
  Modelica.Blocks.Interfaces.RealInput P_SVE annotation (Placement(transformation(extent={{-122,58},
            {-82,98}})));
  TransiEnt.Basics.Blocks.FilterPosNeg Filter annotation (Placement(transformation(extent={{-82,-54},
            {-74,-46}})));
  Modelica.Blocks.Sources.RealExpression Q_flow1(y=P_el_n)                    annotation (Placement(transformation(extent={{-8,-8},{8,8}},
        rotation=180,
        origin={-30,6})));
  Modelica.Blocks.Continuous.LimPID Control(
    controllerType=Modelica.Blocks.Types.SimpleController.PI,
    k=k,
    Ti=T_i,
    yMax=1,
    yMin=0,
    withFeedForward=false)
    annotation (Placement(transformation(extent={{-56,36},{-36,56}})));
  Modelica.Blocks.Math.Product product2 annotation (Placement(transformation(extent={{-8,-16},
            {12,4}})));
  Modelica.Blocks.Logical.GreaterEqual greaterEqual
    annotation (Placement(transformation(extent={{6,-118},{18,-104}})));
  Modelica.Blocks.Logical.And and1
    annotation (Placement(transformation(extent={{26,-112},{36,-102}})));
  Modelica.Blocks.Math.Product product3 annotation (Placement(transformation(extent={{-36,-20},
            {-20,-4}})));
  Modelica.Blocks.Math.Add      add(k2=-1)
                                         annotation (Placement(transformation(extent={{-24,-94},
            {-16,-86}})));
  Modelica.Blocks.Logical.Switch switch1 annotation (Placement(transformation(
        extent={{8,-8},{-8,8}},
        rotation=180,
        origin={86,0})));
  Modelica.Blocks.Logical.GreaterEqual greaterEqual1
    annotation (Placement(transformation(extent={{52,-4},{60,4}})));
  Modelica.Blocks.Sources.RealExpression zero2(y=0) annotation (Placement(transformation(extent={{56,8},{
            72,24}})));
  Modelica.Blocks.Math.Gain gain(k=0.2)
    annotation (Placement(transformation(extent={{10,12},{20,22}})));
  Basics.Blocks.OnOffRelais           onOffRelais(
    init_state=2,
    t_min_on(displayUnit="min") = 1200,
    t_min_off(displayUnit="min") = 60)                  annotation (Placement(transformation(extent={{64,-4},
            {72,4}})));
  Modelica.Blocks.Logical.And and2
    annotation (Placement(transformation(extent={{44,-108},{56,-96}})));
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

  connect(hysteresis_heater.u, SoC) annotation (Line(points={{-10.7,-83},{-66,-83},
          {-66,-20},{-102,-20}},                                                                                    color={0,0,127}));
  connect(zero1.y,switch2. u3) annotation (Line(points={{58.8,-82},{60.4,-82},{
          60.4,-95.6}},                                                                                     color={0,0,127}));
  connect(hysteresis_heater.y, Not1.u) annotation (Line(points={{4.7,-83},{7,-83}},                color={255,0,255}));
  connect(T, hysteresis_heater.u) annotation (Line(points={{-102,20},{-66,20},{
          -66,-83},{-10.7,-83}},                                                                                        color={0,0,127}));
  if not MinTimes or Modulating then
  end if;
  connect(firstOrder1.y, P_set_electricHeater)
    annotation (Line(points={{94.5,-69},{109,-69}}, color={0,0,127}));
  connect(switch2.y, firstOrder1.u) annotation (Line(points={{78.8,-102},{80,
          -102},{80,-72},{82,-72},{82,-69},{83,-69}},
                              color={0,0,127}));
  connect(difference.u1, product1.u1) annotation (Line(points={{-28,-108},{-50,
          -108},{-50,16},{-32,16},{-32,78},{6,78}},
                                             color={0,0,127}));
  connect(product1.y,limiter_HP. limit1) annotation (Line(points={{29,72},{34,
          72},{34,8},{22,8},{22,2}},                                                                            color={0,0,127}));
  connect(Filter.y, product1.u2) annotation (Line(points={{-73.6,-50},{-72,-50},
          {-72,66},{6,66}},                                                     color={0,0,127}));
  connect(Control.y, product2.u1)
    annotation (Line(points={{-35,46},{-12,46},{-12,0},{-10,0}},
                                                       color={0,0,127}));
  connect(T_set, Control.u_s)
    annotation (Line(points={{-102,46},{-58,46}}, color={0,0,127}));
  connect(T, Control.u_m)
    annotation (Line(points={{-102,20},{-46,20},{-46,34}}, color={0,0,127}));
  connect(P_set_electricHeater, P_set_electricHeater) annotation (Line(
      points={{109,-69},{109,-69}},
      color={0,135,135},
      pattern=LinePattern.Dash));
  connect(product2.y, limiter_HP.u)
    annotation (Line(points={{13,-6},{22,-6}},
                                             color={0,0,127}));
  connect(P_SVE, product1.u1)
    annotation (Line(points={{-102,78},{6,78}},  color={0,0,127}));
  connect(division.y, difference.u2) annotation (Line(points={{-39,-124},{-20,
          -124},{-20,-116}},
                       color={0,0,127}));
  connect(Filter.u, COP)
    annotation (Line(points={{-82.8,-50},{-102,-50}}, color={0,0,127}));
  connect(limiter_HP.y, division.u1) annotation (Line(points={{45,-6},{48,-6},{
          48,-40},{-64,-40},{-64,-112},{-68,-112},{-68,-118},{-62,-118}},
                                                 color={0,0,127}));
  connect(P_Heater.y, switch2.u1) annotation (Line(points={{-15.2,-133},{60.4,-133},
          {60.4,-108.4}}, color={0,0,127}));
  connect(difference.y, greaterEqual.u1) annotation (Line(points={{-11,-108},{
          4.8,-111}},                  color={0,0,127}));
  connect(greaterEqual.u2, P_Heater.y) annotation (Line(points={{4.8,-116.6},{
          4.8,-133},{-15.2,-133}},
                               color={0,0,127}));
  connect(and1.u1, Not1.y) annotation (Line(points={{25,-107},{24,-107},{24,-84},
          {18.5,-84},{18.5,-83}}, color={255,0,255}));
  connect(greaterEqual.y, and1.u2) annotation (Line(points={{18.6,-111},{25,
          -111}},                     color={255,0,255}));
  connect(division.u2, product1.u2) annotation (Line(points={{-62,-130},{-72,
          -130},{-72,-58},{-68,-58},{-68,-44},{-72,-44},{-72,66},{6,66}},
                                                                 color={0,0,127}));
  connect(product2.u2, product3.y) annotation (Line(points={{-10,-12},{-19.2,
          -12}},          color={0,0,127}));
  connect(product3.u2, product1.u2) annotation (Line(points={{-37.6,-16.8},{-46,
          -16.8},{-46,12},{-28,12},{-28,66},{6,66}},
                           color={0,0,127}));
  connect(Q_flow1.y, product3.u1) annotation (Line(points={{-38.8,6},{-42,6},{
          -42,-7.2},{-37.6,-7.2}},
                        color={0,0,127}));
  connect(hysteresis_heater.uHigh, Control.u_s) annotation (Line(points={{-10.42,
          -77.4},{-60,-77.4},{-60,46},{-58,46}},        color={0,0,127}));
  connect(hysteresis_heater.uLow, add.y) annotation (Line(points={{-10.7,-88.6},
          {-14,-88.6},{-14,-90},{-15.6,-90}}, color={0,0,127}));
  connect(add.u2, uLow3.y) annotation (Line(points={{-24.8,-92.4},{-32,-92.4},{
          -32,-92},{-29.3,-92}}, color={0,0,127}));
  connect(add.u1, Control.u_s) annotation (Line(points={{-24.8,-87.6},{-34,
          -87.6},{-34,-77.4},{-60,-77.4},{-60,46},{-58,46}}, color={0,0,127}));
  connect(limiter_HP.y, switch1.u1)
    annotation (Line(points={{45,-6},{76.4,-6},{76.4,-6.4}}, color={0,0,127}));
  connect(switch1.y, Q_flow_set_HP) annotation (Line(points={{94.8,-4.44089e-16},
          {92,-4.44089e-16},{92,0},{108,0}}, color={0,0,127}));
  connect(zero2.y, switch1.u3) annotation (Line(points={{72.8,16},{76.4,16},{
          76.4,6.4}}, color={0,0,127}));
  connect(gain.u, product3.y) annotation (Line(points={{9,17},{-18,17},{-18,-12},
          {-19.2,-12}}, color={0,0,127}));
  connect(gain.y, greaterEqual1.u2) annotation (Line(points={{20.5,17},{34,17},
          {34,18},{48,18},{48,-3.2},{51.2,-3.2}},
                                              color={0,0,127}));
  connect(limiter_HP.limit2, gain.y) annotation (Line(points={{22,-14},{16,-14},
          {16,10},{24,10},{24,17},{20.5,17}}, color={0,0,127}));
  connect(greaterEqual1.u1, limiter_HP.u) annotation (Line(points={{51.2,0},{46,
          0},{46,6},{18,6},{18,-6},{22,-6}}, color={0,0,127}));
  connect(greaterEqual1.y, onOffRelais.u)
    annotation (Line(points={{60.4,0},{63.84,0}}, color={255,0,255}));
  connect(switch1.u2, onOffRelais.y) annotation (Line(points={{76.4,1.9984e-15},
          {74,1.9984e-15},{74,0},{72.4,0}}, color={255,0,255}));
  connect(and1.y, and2.u2)
    annotation (Line(points={{36.5,-107},{42.8,-106.8}}, color={255,0,255}));
  connect(switch2.u2, and2.y)
    annotation (Line(points={{60.4,-102},{56.6,-102}}, color={255,0,255}));
  connect(and2.u1, switch1.u2) annotation (Line(points={{42.8,-102},{40,-102},{
          40,-56},{74,-56},{74,0},{76.4,0}}, color={255,0,255}));
  annotation (Diagram(coordinateSystem(extent={{-100,-140},{100,100}}), graphics={
        Rectangle(
          extent={{-46,-66},{22,-98}},
          lineColor={0,0,0},
          pattern=LinePattern.Dash),
        Text(
          extent={{-48,-62},{22,-64}},
          lineColor={0,0,0},
          pattern=LinePattern.Dash,
          fontSize=8,
          textString="Threshold for electric heater")}),                 Icon(
        coordinateSystem(extent={{-100,-140},{100,100}})),
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
end Control_Heat_HotWater;
