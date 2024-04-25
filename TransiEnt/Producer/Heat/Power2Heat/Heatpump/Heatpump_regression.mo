﻿within TransiEnt.Producer.Heat.Power2Heat.Heatpump;
model Heatpump_regression
  "Simple heatpump model that is based on regression models from the hplib python library."

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

 outer TransiEnt.SimCenter simCenter;
 outer TransiEnt.ModelStatistics modelStatistics;

   //___________________________________________________________________________
   //
   //                      Parameters
   //___________________________________________________________________________

  parameter Boolean use_T_source_input_K=false "False, use outer ambient conditions" annotation (Dialog(group="Heat pump parameters"),choices(checkBox=true));
  parameter Boolean use_T_storage=true "False, use constant suppyl temperature defined by T_set" annotation (Dialog(group="Heat pump parameters"), choices(checkBox=true));
  parameter Boolean usePowerPort=true "True if power port shall be used" annotation (Dialog(group="Fundamental Definitions"), choices(checkBox=true));
  parameter Boolean useElectricSetValue=false "True if set value shall be elctrical instead of thermal" annotation (Dialog(group="Fundamental Definitions"), choices(checkBox=true));
  parameter Modelica.Units.SI.TemperatureDifference Delta_T_internal=5 "Temperature difference between refrigerant and source/sink temperature" annotation (Dialog(group="Heat pump parameters"));
  parameter Modelica.Units.SI.TemperatureDifference Delta_T_db=2 "Deadband of hysteresis control" annotation (Dialog(group="Heat pump parameters"));
  parameter Modelica.Units.SI.HeatFlowRate Q_flow_n=3.5e3 "Nominal heat flow of heat pump at nominal conditions according to EN14511" annotation (Dialog(group="Heat pump parameters"));

  Modelica.Units.SI.Temperature T_source=simCenter.ambientConditions.temperature.value + 273.15 "Temperature of heat source" annotation (Dialog(group="Heat pump parameters", enable=not use_T_source_input_K), choices(choice=simCenter.ambientConditions.temperature.value + 273.15 "Ambient Temperature", choice=IntegraNet.SimCenter.Ground_Temperature + 273.15 "Ground Temperature"));

  replaceable model ProducerCosts =
      TransiEnt.Components.Statistics.ConfigurationData.PowerProducerCostSpecs.Empty
                                                                                                                   constrainedby
    TransiEnt.Components.Statistics.ConfigurationData.PowerProducerCostSpecs.PartialPowerPlantCostSpecs
                                                                                                                                                                                                            annotation (Dialog(group="Statistics"), __Dymola_choicesAllMatching=true);

  parameter TILMedia.VLEFluidTypes.BaseVLEFluid medium=simCenter.fluid1 "Medium to be used" annotation (choicesAllMatching, Dialog(group="Fundamental Definitions"));
  parameter Boolean useFluidPorts=true "True if fluid ports shall be used" annotation (Dialog(group="Fundamental Definitions"));
  parameter Modelica.Units.SI.Pressure p_drop=simCenter.p_nom[2] - simCenter.p_nom[1] annotation (Dialog(group="Fundamental Definitions", enable=useFluidPorts));

  parameter Boolean useHeatPort=true "True if heat port shall be used" annotation (Dialog(group="Fundamental Definitions", enable=not useFluidPorts));

  parameter Base.HeatpumpTypes HeatPumpType=Base.HeatpumpTypes.H1 "type of heat pump";

  // regression parameters for COP and Q_flow
  // We use the parameters from the generic average model of the regulated air-water heatpumps (Group_id = 1)
protected
  parameter Real HeatPumpData[8]=Base.getHplibData(HeatPumpType);
  parameter Real p1_COP=HeatPumpData[1];
  parameter Real p2_COP=HeatPumpData[2];
  parameter Real p3_COP=HeatPumpData[3];
  parameter Real p4_COP=HeatPumpData[4];

  parameter Real p1_P_el_h=HeatPumpData[5];
  parameter Real p2_P_el_h=HeatPumpData[6];
  parameter Real p3_P_el_h=HeatPumpData[7];
  parameter Real p4_P_el_h=HeatPumpData[8];

   //___________________________________________________________________________
   //
   //                      Variables
   //___________________________________________________________________________

public
  Real COP;
  Real P_el;
  Real Q_flow;
  Real P_el_max;
  Real Q_flow_max;
  Real T_supply;
  Real COP_n = p1_COP * (-7) + p2_COP * (52) + p3_COP + p4_COP *(-7); // COP at -7°C / 52°C
  Modelica.Units.SI.Power P_el_n=Q_flow_n/COP_n;

  input Modelica.Units.SI.Temperature T_set=50+273.15 "Heatpump supply temperature" annotation (Dialog(group="Heat pump parameters", enable=not use_T_storage));

   //___________________________________________________________________________
   //
   //                      Interfaces
   //___________________________________________________________________________

  TransiEnt.Basics.Interfaces.General.TemperatureIn T_storage if use_T_storage "Setpoint value, e.g. Storage setpoint temperature" annotation (Placement(transformation(extent={{-126,40},{-86,80}})));
  TransiEnt.Basics.Interfaces.General.TemperatureIn T_source_input_K if use_T_source_input_K "Temperature of source" annotation (Placement(transformation(extent={{-20,-20},{20,20}},
        rotation=-90,
        origin={0,106}), iconTransformation(extent={{-20,-20},{20,20}},
        rotation=-90,
        origin={2,104})));

  Modelica.Blocks.Interfaces.RealInput Set_value "Heatflow or electric power set point" annotation (Placement(transformation(extent={{-126,-74},{-86,-34}}), iconTransformation(extent={{-126,-74},{-86,-34}})));
  TransiEnt.Basics.Interfaces.Thermal.HeatFlowRateOut Heat_output    "Setpoint value, e.g. Storage setpoint temperature"  annotation (Placement(transformation(extent={{96,38},{136,78}}),
        iconTransformation(extent={{96,38},{136,78}})));

  replaceable connector PowerPortModel =
      TransiEnt.Basics.Interfaces.Electrical.ActivePowerPort                                    constrainedby
    TransiEnt.Basics.Interfaces.Electrical.ActivePowerPort                                                                                         "Choice of power port" annotation (
    choicesAllMatching=true,
    Dialog(group="Replaceable Components"));

   PowerPortModel epp if usePowerPort annotation (
    Placement(transformation(extent={{66,-110},{86,-90}})));

  TransiEnt.Basics.Interfaces.Thermal.FluidPortIn inlet(Medium=medium) if useFluidPorts annotation (Placement(transformation(extent={{94,-68},{114,-48}}),iconTransformation(extent={{90,-48},{110,-28}})));
  TransiEnt.Basics.Interfaces.Thermal.FluidPortOut outlet(Medium=medium) if useFluidPorts annotation (Placement(transformation(extent={{92,20},{112,40}}), iconTransformation(extent={{92,20},{112,40}})));

  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_b heatPort if (useHeatPort) and not
                                                                                       (useFluidPorts) annotation (Placement(transformation(extent={{90,68},
            {110,88}})));

  // _____________________________________________
  //
  //           Instances of other Classes
  // _____________________________________________

  TransiEnt.Components.Statistics.Collectors.LocalCollectors.HeatingPlantCost heatingPlantCost(
    calculateCost=true,
    consumes_H_flow=false,
    Q_flow_n=Q_flow_n,
    Q_flow_is=-P_el,
    produces_m_flow_CDE=false,
    m_flow_CDE_is=0) annotation (Placement(transformation(extent={{-60,-100},{-40,-80}})));

  replaceable model heatFlowBoundaryModel =
  TransiEnt.Components.Boundaries.Heat.Heatflow_L1 constrainedby
    TransiEnt.Components.Boundaries.Heat.Heatflow_L1
                                       annotation (choicesAllMatching=true,
    Dialog(group="Replaceable Components"));

  heatFlowBoundaryModel heatFlowBoundary(
    p_drop=p_drop,
    Medium=medium,
    change_sign=true,
    use_Q_flow_in=true) if useFluidPorts annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={18,-44})));
  TransiEnt.Components.Sensors.TemperatureSensor T_in_sensor if useFluidPorts annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=180,
        origin={80,-40})));
  TransiEnt.Components.Sensors.TemperatureSensor T_out_sensor if useFluidPorts annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=180,
        origin={78,44})));
  TransiEnt.Components.Sensors.SpecificEnthalpySensorVLE specificEnthalpySensorVLE if useFluidPorts annotation (Placement(transformation(extent={{52,-16},{72,4}})));
  ClaRa.Components.Sensors.SensorVLE_L1_m_flow massFlowSensorVLE if useFluidPorts annotation (Placement(transformation(extent={{28,-16},{48,4}})));
  TransiEnt.Components.Sensors.SpecificEnthalpySensorVLE specificEnthalpySensorVLE1 if useFluidPorts annotation (Placement(transformation(extent={{42,-50},{62,-30}})));

  replaceable model PowerBoundaryModel =
      TransiEnt.Components.Boundaries.Electrical.ActivePower.Power                                    constrainedby
    TransiEnt.Components.Boundaries.Electrical.Base.PartialModelPowerBoundary                                                                                                                  "Choice of power boundary model. The power boundary model must match the power port."     annotation (
    choicesAllMatching=true,
    Dialog(group="Replaceable Components"));

  PowerBoundaryModel Power if usePowerPort "Choice of power boundary model. The power boundary model must match the power port."     annotation (
    Placement(transformation(extent={{-6,-90},{-26,-70}})));

  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow if not (useFluidPorts) and (useHeatPort) annotation (Placement(transformation(extent={{46,68},
            {66,88}})));

  TransiEnt.Basics.Interfaces.General.TemperatureOut T_source_internal "Temperature of heat source used for calculation";

  //Statistics
public
   TransiEnt.Components.Statistics.Collectors.LocalCollectors.CollectElectricPower collectElectricPower(typeOfResource=TransiEnt.Basics.Types.TypeOfResource.Consumer) annotation (Placement(transformation(extent={{-100,-100},{-80,-80}})));
   TransiEnt.Components.Statistics.Collectors.LocalCollectors.CollectHeatingPower collectHeatingPower(typeOfResource=TransiEnt.Basics.Types.TypeOfResource.Conventional)
                                                                                                                                                                    annotation (Placement(transformation(extent={{-80,-100},{-60,-80}})));

  Modelica.Blocks.Sources.RealExpression Q_flow_output(y=Q_flow) annotation (Placement(transformation(extent={{-32,16},{-12,36}})));
equation

  // _____________________________________________
  //
  //           Characteristic Equations
  // _____________________________________________

   if not use_T_source_input_K then
     T_source_internal =T_source;
   end if;

   //Calculate Supply Temperature if heat storage temperature is given else use constant suppy temperature defined by T_set
   if use_T_storage then
     T_supply = T_storage + 5;
   else
     T_supply = T_set;
   end if;

   // Apply Regression Model for COP
   COP =  p1_COP * (T_source - 273.15) + p2_COP * (T_supply - 273.15) + p3_COP + p4_COP *(T_source - 273.15); // The temperatures has to be given in °C

   //We should somehow account for a maximum possible thermal or electricel power that is given within the regression models
   P_el_max = P_el_n * (p1_P_el_h * (T_source - 273.15) + p2_P_el_h * (T_supply - 273.15) + p3_P_el_h + p4_P_el_h *(T_source - 273.15)); // The temperatures has to be given in °C
   Q_flow_max = COP*P_el_max;

   Q_flow = P_el*COP;
   Power.P_el_set = P_el;
   //Q_flow = Q_flow_set;

  if not useElectricSetValue then
    if Set_value > Q_flow_max then
     Q_flow = Q_flow_max;
   else
     Q_flow = Set_value;
    end if;
  else
    if Set_value > P_el_max then
      P_el = P_el_max;
    else
      P_el = Set_value;
    end if;
  end if;

   collectElectricPower.powerCollector.P=-P_el;
   collectHeatingPower.heatFlowCollector.Q_flow=Q_flow;

  connect(T_source_internal, T_source_input_K);
  connect(modelStatistics.powerCollector[collectElectricPower.typeOfResource],collectElectricPower.powerCollector);
  connect(modelStatistics.heatFlowCollector[collectHeatingPower.typeOfResource],collectHeatingPower.heatFlowCollector);
  connect(modelStatistics.costsCollector, heatingPlantCost.costsCollector);

  connect(T_in_sensor.port,inlet)  annotation (Line(
      points={{80,-50},{80,-58},{104,-58}},
      color={0,0,0},
      smooth=Smooth.None));
  connect(outlet,T_out_sensor.port) annotation (Line(
      points={{102,30},{78,30},{78,34}},
      color={175,0,0},
      thickness=0.5,
      smooth=Smooth.None));
  connect(outlet,specificEnthalpySensorVLE.outlet) annotation (Line(
      points={{102,30},{68,30},{68,8},{80,8},{80,-16},{72,-16}},
      color={175,0,0},
      thickness=0.5));
  connect(specificEnthalpySensorVLE.inlet,massFlowSensorVLE.outlet) annotation (Line(
      points={{52,-16},{52,-20},{48,-20},{48,-16}},
      color={0,131,169},
      pattern=LinePattern.Solid,
      thickness=0.5));
  connect(heatFlowBoundary.fluidPortOut,massFlowSensorVLE.inlet) annotation (Line(
      points={{28,-38},{32,-38},{32,-20},{28,-20},{28,-16}},
      color={175,0,0},
      thickness=0.5));
  connect(inlet,specificEnthalpySensorVLE1.outlet) annotation (Line(
      points={{104,-58},{104,-56},{62,-56},{62,-50}},
      color={175,0,0},
      thickness=0.5));
  connect(heatFlowBoundary.fluidPortIn,specificEnthalpySensorVLE1.inlet) annotation (Line(
      points={{28,-50},{36,-50},{36,-54},{42,-54},{42,-50}},
      color={175,0,0},
      thickness=0.5));
  connect(prescribedHeatFlow.port, heatPort) annotation (Line(points={{66,78},{100,78}}, color={191,0,0}));
  connect(Power.epp, epp) annotation (Line(
      points={{-6,-80},{76,-80},{76,-100}},
      color={0,135,135},
      thickness=0.5));
  connect(Q_flow_output.y, heatFlowBoundary.Q_flow_prescribed) annotation (Line(points={{-11,26},{4,26},{4,-50},{10,-50}}, color={0,0,127}));
  connect(Q_flow_output.y, prescribedHeatFlow.Q_flow) annotation (Line(points={{-11,26},{40,26},{40,78},{46,78}}, color={0,0,127}));
  connect(Q_flow_output.y, Heat_output) annotation (Line(points={{-11,26},{40,26},{40,58},{116,58}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
                                   Ellipse(
          lineColor={0,125,125},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          extent={{-100,-100},{100,100}}),
        Rectangle(
          extent={{-38,40},{42,-48}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-48,8},{-44,8},{-30,8},{-38,-4},{-30,-14},{-48,-14},{-38,-4},{-48,8}},
          lineColor={0,0,0},
          smooth=Smooth.None,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-18,48},{20,32}},
          lineColor={0,0,0},
          fillColor={255,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-16,-40},{22,-56}},
          lineColor={0,0,0},
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{30,10},{56,-14}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Line(
          points={{34,-10},{42,10},{52,-10}},
          color={0,0,0},
          smooth=Smooth.None),
        Line(
          points={{-20,22},{-20,-24},{28,-24}},
          color={0,0,0},
          smooth=Smooth.None),
        Line(
          points={{-20,-22},{-16,-14},{-4,4},{-2,6},{6,12},{16,16},{24,16}},
          color={0,0,255},
          smooth=Smooth.None)}),                                 Diagram(coordinateSystem(preserveAspectRatio=false)),
    Documentation(info="<html>
<p><b><span style=\"color: #008000;\">1. Purpose of model</span></b></p>
<p>(no remarks)</p>
<p><b><span style=\"color: #008000;\">2. Level of detail, physical effects considered, and physical insight</span></b></p>
<p> (no remarks)</p>
<p><b><span style=\"color: #008000;\">3. Limits of validity </span></b></p>
<p>(no remarks)</p>
<p><b><span style=\"color: #008000;\">4. Interfaces</span></b></p>
<p>(no remarks)</p>
<p><b><span style=\"color: #008000;\">5. Nomenclature</span></b></p>
<p>(no elements)</p>
<p><b><span style=\"color: #008000;\">6. Governing Equations</span></b></p>
<p>(no remarks)</p>
<p><b><span style=\"color: #008000;\">7. Remarks for Usage</span></b></p>
<p>(no remarks)</p>
<p><b><span style=\"color: #008000;\">8. Validation</span></b></p>
<p>not validated yet</p>
<p><b><span style=\"color: #008000;\">9. References</span></b></p>
<p>(no remarks)</p>
<p><b><span style=\"color: #008000;\">10. Version History</span></b></p>
<p>(no remarks)</p>
</html>"));
end Heatpump_regression;