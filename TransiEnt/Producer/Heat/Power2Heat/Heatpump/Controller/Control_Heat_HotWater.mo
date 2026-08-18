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

  input Modelica.Units.SI.Temperature TLow_HP=(273.15 + 22) "Set Temperature for summer" annotation (Dialog(group="Temperature limits"));
  input Modelica.Units.SI.Temperature THigh_HP=(273.15 + 60)
                                                 "Temperature limit in case of excess PV energy" annotation (Dialog(group="Temperature limits"));


  parameter Real Threshold=P_el_max*0.2 "Excess PV power to start heat pump operation" annotation (Dialog(group="Control parameters"));

  parameter Integer n_HeaterStages(min=1)=1 "Discrete power stages of the electric heater (1 = on/off, 3 = thirds). Stage selected demand-based (storage temperature deficit) and capped by the available electric headroom." annotation (Dialog(group="Control parameters"));
  parameter Modelica.Units.SI.TemperatureDifference Delta_T_stage=2 "Storage temperature deficit (T_set - T) that engages one additional heater stage (only used if n_HeaterStages > 1)" annotation (Dialog(group="Control parameters", enable=n_HeaterStages > 1));
  parameter Modelica.Units.SI.TemperatureDifference Delta_T_hyst=1 "Switch-off deadband per heater stage; prevents event chattering at stage boundaries (only if n_HeaterStages > 1)" annotation (Dialog(group="Control parameters", enable=n_HeaterStages > 1));

  parameter Modelica.Units.SI.Temperature T_amb_heaterRelease=293.15 "Electric heater is blocked above this ambient temperature (default: never blocked)" annotation (Dialog(group="Control parameters"));



  parameter Real k=0.1 "PI controller gain" annotation (Dialog(group="PI Controller"));
  parameter Modelica.Units.SI.Time T_i=180 "PI controller time constant" annotation (Dialog(group="PI Controller"));
  parameter Modelica.Units.SI.HeatFlowRate Q_flow_n=10.5e3 "Nominal heat flow of heat pump at nominal conditions according to EN14511 (7/35)" annotation (Dialog(group="Heatpump"));
  parameter SI.Power COP_n=3.5 "Coefficient of performance at nominal conditions according to EN14511 (7/35)" annotation (Dialog(group="Heatpump"));
  parameter Modelica.Units.SI.HeatFlowRate P_el_max=5.0e3 "Maximal electric Power of heat pump at 7°C/55°C" annotation (Dialog(group="Heatpump"));
  parameter Modelica.Units.SI.TemperatureDifference Delta_T_internal=5 "Temperature difference between refrigerant and source/sink temperature" annotation (Dialog(group="Heatpump"));
  parameter Modelica.Units.SI.Temperature T_amb_min=-8 + 273.25 "Heating design temperature" annotation (Dialog(group="Heatpump"));
  final parameter Real eta_HP = COP_n * (28 + 2*Delta_T_internal)
    / (308.15 + Delta_T_internal);
  Modelica.Units.SI.Temperature T_source=simCenter.ambientConditions.temperature.value + 273.15 "Temperature of heat source" annotation (Dialog(group="Heatpump"), choices(choice=simCenter.ambientConditions.temperature.value + 273.15 "Ambient Temperature", choice=IntegraNet.SimCenter.Ground_Temperature + 273.15 "Ground Temperature"));



  Modelica.Units.SI.Power P_el_n=P_el_max - max(0,( 273.15 + 55 - T_set) / (55 - 35) * (P_el_max - Q_flow_n/COP_n));
  Modelica.Units.SI.HeatFlowRate Q_HP_max = P_el_n
           * eta_HP
           * (T_set + Delta_T_internal)
           / max(2 * Delta_T_internal,
                 T_set + 2 * Delta_T_internal - T_source);
  //parameter Modelica.Units.SI.Power P_el_n=Q_flow_n/COP_n "Nominal electrical power of the heatpump";

  // Demand-based staged electric heater command. Each stage has its own
  // hysteresis (per-stage on/off state stage_on[]), so the discrete stages do
  // not chatter. Stage i engages when the storage temperature deficit
  // (T_set - T) exceeds i*Delta_T_stage AND the available electric headroom
  // (difference.y = P_SVE*(P_elHeater+P_el_max) - P_HP_el) covers i stages;
  // it stays on within a deadband (Delta_T_hyst / a small headroom margin).
  // n_HeaterStages=1 keeps the original on/off behaviour (constant P_elHeater,
  // gated downstream by or1/onOffRelais/greaterEqual).
  Modelica.Units.SI.Power P_heater_stage "Staged electric heater power setpoint";
  Boolean stage_on[n_HeaterStages](each start=false) "Per-stage on/off state of the electric heater (hysteresis)";
   //___________________________________________________________________________
   //
   //                      Variables
   //___________________________________________________________________________


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
  Modelica.Blocks.Sources.RealExpression P_Heater(y=P_heater_stage) annotation (Placement(transformation(extent={{-8,-9},{8,9}},
        rotation=0,
        origin={-24,-133})));
  Modelica.Blocks.Logical.Switch switch2 annotation (Placement(transformation(
        extent={{8,-8},{-8,8}},
        rotation=180,
        origin={70,-102})));

  Modelica.Blocks.Continuous.FirstOrder firstOrder1(T=1) if
                                                           Modulating
    annotation (Placement(transformation(extent={{84,-74},{94,-64}})));
  Modelica.Blocks.Math.Product product1 annotation (Placement(transformation(extent={{10,62},
            {30,82}})));
  Modelica.Blocks.Nonlinear.VariableLimiter limiter_HP annotation (Placement(transformation(extent={{46,-16},
            {54,-8}})));
  Modelica.Blocks.Math.Feedback difference
    annotation (Placement(transformation(extent={{-30,-118},{-10,-98}})));
  Modelica.Blocks.Math.Division division annotation (Placement(transformation(extent={{-54,
            -134},{-34,-114}})));
  Modelica.Blocks.Interfaces.RealInput COP annotation (Placement(transformation(extent={{-122,
            -70},{-82,-30}})));
  Modelica.Blocks.Interfaces.RealInput P_SVE annotation (Placement(transformation(extent={{-122,58},
            {-82,98}})));
  TransiEnt.Basics.Blocks.FilterPosNeg Filter annotation (Placement(transformation(extent={{-82,-54},
            {-74,-46}})));
  Modelica.Blocks.Sources.RealExpression Q_flow1(y=P_el_n)                    annotation (Placement(transformation(extent={{-8,-8},{8,8}},
        rotation=180,
        origin={-44,6})));
  Modelica.Blocks.Continuous.LimPID Control(
    controllerType=Modelica.Blocks.Types.SimpleController.PI,
    k=Q_flow_n*k,
    Ti=T_i,
    yMax=Q_flow_n,
    yMin=0,
    withFeedForward=false)
    annotation (Placement(transformation(extent={{-36,36},{-16,56}})));
  Modelica.Blocks.Logical.GreaterEqual greaterEqual
    annotation (Placement(transformation(extent={{6,-118},{18,-104}})));
  Modelica.Blocks.Logical.And and1
    annotation (Placement(transformation(extent={{26,-112},{36,-102}})));
  Modelica.Blocks.Math.Product product3 annotation (Placement(transformation(extent={{-50,-20},
            {-34,-4}})));
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
    t_min_on(displayUnit="min") = t_min_on,
    t_min_off(displayUnit="min") = t_min_off)           annotation (Placement(transformation(extent={{64,-4},
            {72,4}})));
  Modelica.Blocks.Logical.And and2
    annotation (Placement(transformation(extent={{44,-108},{56,-96}})));
  Basics.Blocks.FilterPosNeg           Filter1
                                              annotation (Placement(transformation(extent={{-2,-2},
            {2,2}},
        rotation=0,
        origin={12,-4})));
  Basics.Blocks.Sources.PowerExpression powerExpression(y=P_elHeater + P_el_max)
    annotation (Placement(transformation(extent={{-64,76},{-44,96}})));
  Modelica.Blocks.Math.Product product4 annotation (Placement(transformation(extent={{-22,70},
            {-6,86}})));
  Modelica.Blocks.Nonlinear.VariableLimiter limiter_HP1
                                                       annotation (Placement(transformation(extent={{30,-16},
            {38,-8}})));
  Modelica.Blocks.Logical.LessThreshold lessThreshold(threshold=T_amb_min)
    annotation (Placement(transformation(extent={{10,-70},{18,-62}})));
  Modelica.Blocks.Logical.Or or1
    annotation (Placement(transformation(extent={{24,-84},{34,-74}})));
  Modelica.Blocks.Logical.LessThreshold heaterRelease(threshold=T_amb_heaterRelease)
    annotation (Placement(transformation(extent={{24,-124},{32,-116}})));
  Modelica.Blocks.Logical.And and3
    annotation (Placement(transformation(extent={{42,-124},{52,-114}})));
  Basics.Interfaces.General.ControlBus controlBus                  annotation (Placement(transformation(extent={{-120,
            -120},{-80,-80}}),                                                                                                         iconTransformation(extent={{-120,-20},{-80,20}})));
equation
  // ___________________________________________________________________________
  //
  //            Characteristic equations
  // ___________________________________________________________________________

  // Demand-based staged electric heater with per-stage hysteresis (event-stable,
  // no floor()). Stage i turns ON when the storage deficit (T_set - T) exceeds
  // i*Delta_T_stage AND the electric headroom (difference.y) covers i stages; it
  // stays ON while the deficit is within a deadband (Delta_T_hyst) and the
  // headroom still covers i stages. The deficit deadband stops the chattering at
  // the demand side (the storage temperature is actively controlled near a stage
  // threshold); the headroom uses the same threshold for on and stay so that the
  // downstream greaterEqual power gate stays consistent (difference.y is stable
  // anyway while the heat pump is saturated). hysteresis_heater.u carries the
  // controlled storage temperature (= T, or SoC in SoC mode); using it instead of
  // the conditional connector T keeps this valid in both control modes.
  for i in 1:n_HeaterStages loop
    stage_on[i] = if n_HeaterStages <= 1 then false
      else ((T_set - hysteresis_heater.u) > i*Delta_T_stage
                and difference.y >= i*(P_elHeater/n_HeaterStages))
           or (pre(stage_on[i])
                and (T_set - hysteresis_heater.u) > i*Delta_T_stage - Delta_T_hyst
                and difference.y >= i*(P_elHeater/n_HeaterStages));
  end for;
  if n_HeaterStages <= 1 or P_elHeater <= 0 then
    P_heater_stage = P_elHeater;
  else
    P_heater_stage = sum(if stage_on[i] then P_elHeater/n_HeaterStages else 0
                         for i in 1:n_HeaterStages);
  end if;


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
  connect(product1.y,limiter_HP. limit1) annotation (Line(points={{31,72},{38,
          72},{38,-4},{45.2,-4},{45.2,-8.8}},                                                                   color={0,0,127}));
  connect(Filter.y, product1.u2) annotation (Line(points={{-73.6,-50},{-72,-50},
          {-72,66},{8,66}},                                                     color={0,0,127}));
  connect(T, Control.u_m)
    annotation (Line(points={{-102,20},{-26,20},{-26,34}}, color={0,0,127}));
  connect(P_set_electricHeater, P_set_electricHeater) annotation (Line(
      points={{109,-69},{109,-69}},
      color={0,135,135},
      pattern=LinePattern.Dash));
  connect(division.y, difference.u2) annotation (Line(points={{-33,-124},{-20,
          -124},{-20,-116}},
                       color={0,0,127}));
  connect(Filter.u, COP)
    annotation (Line(points={{-82.8,-50},{-102,-50}}, color={0,0,127}));
  connect(limiter_HP.y, division.u1) annotation (Line(points={{54.4,-12},{66,
          -12},{66,-52},{-60,-52},{-60,-118},{-56,-118}},
                                                 color={0,0,127}));
  connect(difference.y, greaterEqual.u1) annotation (Line(points={{-11,-108},{
          4.8,-111}},                  color={0,0,127}));
  connect(greaterEqual.u2, P_Heater.y) annotation (Line(points={{4.8,-116.6},{
          4.8,-133},{-15.2,-133}},
                               color={0,0,127}));
  connect(greaterEqual.y, and1.u2) annotation (Line(points={{18.6,-111},{25,
          -111}},                     color={255,0,255}));
  connect(division.u2, product1.u2) annotation (Line(points={{-56,-130},{-72,
          -130},{-72,-58},{-68,-58},{-68,-44},{-72,-44},{-72,66},{8,66}},
                                                                 color={0,0,127}));
  connect(product3.u2, product1.u2) annotation (Line(points={{-51.6,-16.8},{-60,
          -16.8},{-60,12},{-42,12},{-42,66},{8,66}},
                           color={0,0,127}));
  connect(Q_flow1.y, product3.u1) annotation (Line(points={{-52.8,6},{-56,6},{
          -56,-7.2},{-51.6,-7.2}},
                        color={0,0,127}));
  connect(hysteresis_heater.uLow, add.y) annotation (Line(points={{-10.7,-88.6},
          {-14,-88.6},{-14,-90},{-15.6,-90}}, color={0,0,127}));
  connect(add.u2, uLow3.y) annotation (Line(points={{-24.8,-92.4},{-32,-92.4},{
          -32,-92},{-29.3,-92}}, color={0,0,127}));
  connect(limiter_HP.y, switch1.u1)
    annotation (Line(points={{54.4,-12},{76.4,-12},{76.4,-6.4}},
                                                             color={0,0,127}));
  connect(switch1.y, Q_flow_set_HP) annotation (Line(points={{94.8,-4.44089e-16},
          {92,-4.44089e-16},{92,0},{108,0}}, color={0,0,127}));
  connect(zero2.y, switch1.u3) annotation (Line(points={{72.8,16},{76.4,16},{
          76.4,6.4}}, color={0,0,127}));
  connect(gain.u, product3.y) annotation (Line(points={{9,17},{-32,17},{-32,-12},
          {-33.2,-12}}, color={0,0,127}));
  connect(gain.y, greaterEqual1.u2) annotation (Line(points={{20.5,17},{24,17},
          {24,10},{48,10},{48,-3.2},{51.2,-3.2}},
                                              color={0,0,127}));
  connect(greaterEqual1.y, onOffRelais.u)
    annotation (Line(points={{60.4,0},{63.84,0}}, color={255,0,255}));
  connect(switch1.u2, onOffRelais.y) annotation (Line(points={{76.4,1.9984e-15},
          {74,1.9984e-15},{74,0},{72.4,0}}, color={255,0,255}));
  connect(and1.y, and2.u2)
    annotation (Line(points={{36.5,-107},{42.8,-106.8}}, color={255,0,255}));
  connect(and2.y, and3.u1)
    annotation (Line(points={{56.6,-102},{58,-102},{58,-112},{40,-112},{40,-119},{41,-119}}, color={255,0,255}));
  connect(heaterRelease.y, and3.u2)
    annotation (Line(points={{32.4,-120},{36,-120},{36,-123},{41,-123}}, color={255,0,255}));
  connect(and3.y, switch2.u2)
    annotation (Line(points={{52.5,-119},{56,-119},{56,-102},{60.4,-102}}, color={255,0,255}));
  connect(hysteresis_heater.uHigh, T_set) annotation (Line(points={{-10.42,
          -77.4},{-64,-77.4},{-64,46},{-102,46}}, color={0,0,127}));
  connect(add.u1, T_set) annotation (Line(points={{-24.8,-87.6},{-24,-87.6},{
          -24,-88},{-64,-88},{-64,46},{-102,46}}, color={0,0,127}));
  connect(T_set, Control.u_s)
    annotation (Line(points={{-102,46},{-38,46}}, color={0,0,127}));
  connect(product4.y, product1.u1)
    annotation (Line(points={{-5.2,78},{8,78}}, color={0,0,127}));
  connect(powerExpression.y, product4.u1) annotation (Line(
      points={{-43,86},{-28,86},{-28,82.8},{-23.6,82.8}},
      color={0,135,135},
      pattern=LinePattern.Dash));
  connect(P_SVE, product4.u2) annotation (Line(points={{-102,78},{-68,78},{-68,
          73.2},{-23.6,73.2}}, color={0,0,127}));
  connect(product4.y, difference.u1) annotation (Line(points={{-5.2,78},{2,78},{
          2,-50},{-52,-50},{-52,-108},{-28,-108}},  color={0,0,127}));
  connect(greaterEqual1.u1, Filter1.y) annotation (Line(points={{51.2,0},{20,0},
          {20,-4},{14.2,-4}}, color={0,0,127}));
  connect(limiter_HP.u, limiter_HP1.y)
    annotation (Line(points={{45.2,-12},{38.4,-12}}, color={0,0,127}));
  connect(gain.y, limiter_HP1.limit2) annotation (Line(points={{20.5,17},{24,17},
          {24,-16},{29.2,-16},{29.2,-15.2}}, color={0,0,127}));
  connect(Filter1.y, limiter_HP1.u) annotation (Line(points={{14.2,-4},{22,-4},
          {22,-12},{29.2,-12}}, color={0,0,127}));
  connect(zero2.y, limiter_HP.limit2) annotation (Line(points={{72.8,16},{76,16},
          {76,28},{42,28},{42,-15.2},{45.2,-15.2}}, color={0,0,127}));
  connect(gain.u, limiter_HP1.limit1) annotation (Line(points={{9,17},{9,4.5},{
          29.2,4.5},{29.2,-8.8}}, color={0,0,127}));
  connect(lessThreshold.y, or1.u1) annotation (Line(points={{18.4,-66},{20,-66},
          {20,-79},{23,-79}}, color={255,0,255}));
  connect(or1.y, and2.u1) annotation (Line(points={{34.5,-79},{38,-79},{38,-102},
          {42.8,-102}}, color={255,0,255}));
  connect(onOffRelais.y, and1.u1) annotation (Line(points={{72.4,0},{72.4,-70},{
          40,-70},{40,-98},{22,-98},{22,-107},{25,-107}}, color={255,0,255}));
  connect(Not1.y, or1.u2)
    annotation (Line(points={{18.5,-83},{23,-83}}, color={255,0,255}));
  connect(switch2.u1, P_Heater.y) annotation (Line(points={{60.4,-108.4},{60.4,-133},
    {-15.2,-133}}, color={0,0,127}));
  connect(controlBus.ambientConditions.ambientTemperature,lessThreshold.u);
  connect(controlBus.ambientConditions.ambientTemperature,heaterRelease.u);
  connect(Filter1.u, Control.y) annotation (Line(points={{9.6,-4},{-2,-4},{-2,46},
          {-15,46}}, color={0,0,127}));
  annotation (Diagram(coordinateSystem(extent={{-100,-140},{100,100}}), graphics={
        Rectangle(
          extent={{-48,-54},{36,-96}},
          lineColor={0,0,0},
          pattern=LinePattern.Dash),
        Text(
          extent={{-48,-54},{22,-56}},
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
