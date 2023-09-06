within TransiEnt.Consumer.Systems.HouseholdEnergyConverter.Systems;
model HeatPump_Peakboiler "HeatPump with peak boiler and thermal storage"

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
    DHN=false,
    el_grid=true,
    gas_grid=false);

  outer TransiEnt.SimCenter simCenter;
  outer TransiEnt.ModelStatistics modelStatistics;

  // _____________________________________________
  //
  //          Parameters
  // _____________________________________________

  parameter Boolean hotwater=true "Does the heat pump provide energy for the hot water? (if false: water is heated electrically)" annotation (
    HideResult=true,
    Dialog(group="System setup"),
    choices(checkBox=true));
  parameter Boolean hotwater_booster=false "Does the heat pump provide energy for hot water partially?" annotation (
    HideResult=true,
    Dialog(group="System setup"),
    choices(checkBox=true));
  parameter Boolean heating=true "Does the heat pump provide energy for space heating? (if false: space heating not accounted for)" annotation (
    HideResult=true,
    Dialog(group="System setup"),
    choices(checkBox=true));

  parameter Modelica.Units.SI.TemperatureDifference Delta_T_internal=5 "Temperature difference between refrigerant and source/sink temperature" annotation (HideResult=true, Dialog(group="Heatpump"));
  parameter Modelica.Units.SI.TemperatureDifference Delta_T_db=2 "Deadband of hysteresis control" annotation (HideResult=true, Dialog(group="Heatpump"));
  parameter Modelica.Units.SI.HeatFlowRate Q_flow_n=3.5e3 "Nominal heat flow of heat pump at nominal conditions according to EN14511" annotation (HideResult=true, Dialog(group="Heatpump"));
  parameter Real COP_n=3.7 "Coefficient of performance at nominal conditions according to EN14511" annotation (HideResult=true, Dialog(group="Heatpump"));

  parameter Modelica.Units.SI.HeatFlowRate Q_flow_n_boiler=10e3 "Power of the peak boiler" annotation (HideResult=true, Dialog(group="Peak Boiler"));
  parameter Modelica.Units.SI.Efficiency eta=1.05 "Efficiency of the backup heater" annotation (HideResult=true, Dialog(group="Peak Boiler"));
  parameter TILMedia.VLEFluidTypes.BaseVLEFluid FuelMedium=simCenter.gasModel1 "Fuel gas medium" annotation (HideResult=true, Dialog(group="Fluid Definition", enable=useGasPort));
  parameter Modelica.Units.SI.SpecificEnthalpy HoC_fuel=simCenter.HeatingValue_natGas "Heat of combustion of fuel, will be used if gasport is deactivated in model" annotation (Dialog(enable=not useGasPort, group="Fluid Definition"), choices(
      choice=simCenter.HeatingValue_natGas "natural gas",
      choice=simCenter.HeatingValue_oil "Oil",
      choice=simCenter.HeatingValue_pellets "wood pellets"));
  parameter Boolean useGasPort=false "True if gas port shall be used" annotation (Dialog(group="System setup"), choices(checkBox=true));
  parameter Basics.Types.TypeOfPrimaryEnergyCarrierHeat typeOfPrimaryEnergyCarrier=TransiEnt.Basics.Types.TypeOfPrimaryEnergyCarrierHeat.NaturalGas "Type of primary energy carrier for co2 emissions global statistics" annotation (Dialog(group="Statistics"));
  replaceable model BoilerCostModel = Components.Statistics.ConfigurationData.PowerProducerCostSpecs.GasBoiler annotation (__Dymola_choicesAllMatching=true, Dialog(group="Statistics"));

  SI.Temperature T_set=heatingCurve.T_supply+3 "Heatpump supply temperature" annotation (Dialog(group="Heatpump"));
  SI.Temperature T_s_max=heatingCurve.T_supply_max "Maximum storage temperature" annotation (HideResult=true, Dialog(group="Storage"));
  SI.Temperature T_s_min=heatingCurve.T_return "Minimum storage temperature" annotation (HideResult=true, Dialog(group="Storage"));
  parameter Modelica.Units.SI.Volume V_Storage=0.5 "Volume of the Storage" annotation (HideResult=true, Dialog(group="Storage"));
  parameter Modelica.Units.SI.Height height=1.3 "Height of heat storage" annotation (HideResult=true, Dialog(group="Storage"));
  parameter Modelica.Units.SI.Diameter d=sqrt(V_Storage/heatStorage.height*4/Modelica.Constants.pi) "Diameter of heat storage" annotation (HideResult=true, Dialog(group="Storage"));
  parameter Modelica.Units.NonSI.Temperature_degC T_amb=15 "Assumed constant ambient temperature" annotation (HideResult=true, Dialog(group="Storage"));
  parameter Modelica.Units.SI.SurfaceCoefficientOfHeatTransfer k=0.08 "Coefficient of heat transfer through tank surface" annotation (HideResult=true, Dialog(group="Storage"));
  parameter Modelica.Units.SI.Temperature T_start=60 + 273.15 "Start value of the storage temperature" annotation (HideResult=true, Dialog(group="Storage"));

  // _____________________________________________
  //
  //                   Variables
  // _____________________________________________

  Modelica.Units.SI.Power P "Consumed or produced electric power";
  Modelica.Units.SI.Temperature T_source=simCenter.ambientConditions.temperature.value + 273.15 "Temperature of heat source" annotation (Dialog(group="Heatpump"));

  // _____________________________________________
  //
  //           Instances of other Classes
  // _____________________________________________

  TransiEnt.Components.Boundaries.Electrical.ApparentPower.ApparentPower apparentPower(
    useInputConnectorQ=false,
    useInputConnectorP=true,
    useCosPhi=false) annotation (Placement(transformation(extent={{-60,-76},{-44,-60}})));

  TransiEnt.Producer.Heat.Power2Heat.Heatpump.Heatpump heatPump(
    Delta_T_internal=Delta_T_internal,
    Delta_T_db=Delta_T_db,
    Q_flow_n=Q_flow_n,
    COP_n=COP_n,
    T_source=T_source,
    useFluidPorts=false,
    useHeatPort=false,
    T_set=heatingCurve.T_supply + 3,
    redeclare connector PowerPortModel = TransiEnt.Basics.Interfaces.Electrical.ApparentPowerPort,
    redeclare model PowerBoundaryModel = TransiEnt.Components.Boundaries.Electrical.ApparentPower.ApparentPower,
    Power(useInputConnectorQ=false, useCosPhi=false)) annotation (Placement(transformation(extent={{16,-22},{38,0}})));

  TransiEnt.Storage.Heat.HotWaterStorage_constProp_L2.HotWaterStorage_constProp_L2 heatStorage(
    useFluidPorts=false,
    T_s_max=T_s_max,
    T_s_min=T_s_min,
    d=d,
    height=height,
    T_amb=T_amb,
    k=k,
    T_start=T_start) annotation (Placement(transformation(extent={{72,32},{92,52}})));

  replaceable TransiEnt.Producer.Heat.Power2Heat.Heatpump.Controller.ControlHeatpump_heatdriven_BVTemp Controller(CalculatePHeater=true)
                                                                                                                  constrainedby TransiEnt.Producer.Heat.Power2Heat.Heatpump.Controller.Base.Controller(
    P_elHeater=Q_flow_n_boiler,
    CalculatePHeater=true,
    Q_flow_n=heatPump.Q_flow_n,
    Delta_T_db=Delta_T_db) "Control mode of the heat pump" annotation (
    Dialog(group="System setup"),
    choicesAllMatching=true,
    Placement(transformation(extent={{-62,-26},{-40,-4}})));

  TransiEnt.Producer.Heat.Gas2Heat.SimpleGasBoiler.SimpleBoiler gasBoiler(
    useFluidPorts=false,
    useHeatPort=false,
    eta=eta,
    Q_flow_n=Q_flow_n_boiler,
    HoC_fuel=HoC_fuel,
    change_sign=true,
    gasMedium=FuelMedium,
    useGasPort=false,
    typeOfPrimaryEnergyCarrier=typeOfPrimaryEnergyCarrier,
    redeclare model BoilerCostModel = BoilerCostModel)      annotation (Placement(transformation(extent={{-2,-48},{18,-28}})));

  Modelica.Blocks.Math.Add add1 if heating and hotwater annotation (Placement(transformation(extent={{30,48},{46,64}})));
  Modelica.Blocks.Math.Add add2 if not hotwater and not hotwater_booster annotation (Placement(transformation(
        extent={{8,-8},{-8,8}},
        rotation=90,
        origin={-52,50})));
  Modelica.Blocks.Math.Add add3 annotation (Placement(transformation(extent={{56,-30},{72,-14}})));

  Modelica.Blocks.Sources.RealExpression Tsource(y=heatPump.T_source_internal) annotation (Placement(transformation(extent={{-46,14},{-30,32}})));

  TransiEnt.Consumer.Heat.DHW_Booster dHW_Booster if hotwater_booster annotation (Placement(transformation(extent={{-12,48},{4,64}})));


  Heat.Profiles.HeatingCurve heatingCurve  annotation (Dialog(group="System setup"), Placement(transformation(
          extent={{-102,-26},{-82,-6}})));
equation

  // _____________________________________________
  //
  //            Characteristic equations
  // _____________________________________________

  P = epp.P;

  // _____________________________________________
  //
  //            Connect statements
  // _____________________________________________

  if heating and hotwater and not hotwater_booster then
    connect(add1.y, heatStorage.Q_flow_demand) annotation (Line(points={{46.8,56},{98,56},{98,42},{92,42}}, color={0,0,127}));
    connect(demand.electricPowerDemand, apparentPower.P_el_set) annotation (Line(points={{4.68,100.48},{-34,100.48},{-34,100},{-74,100},{-74,64},{-76,64},{-76,16},{-92,16},{-92,-48},{-56.8,-48},{-56.8,-58.4}}, color={175,0,0}, pattern=LinePattern.Dash));
  elseif heating and not hotwater_booster then
    connect(demand.heatingPowerDemand, heatStorage.Q_flow_demand) annotation (Line(points={{0,100.48},{0,80},{28,80},{28,68},{98,68},{98,40},{96,40},{96,42},{92,42}}, color={0,127,127}));
    connect(add2.y, apparentPower.P_el_set) annotation (Line(points={{-52,41.2},{-52,16},{-92,16},{-92,-48},{-56.8,-48},{-56.8,-58.4}}, color={0,0,127}));
  elseif hotwater and not hotwater_booster then
    connect(demand.hotWaterPowerDemand, heatStorage.Q_flow_demand) annotation (Line(points={{-4.8,100.48},{-4.8,80},{28,80},{28,68},{100,68},{100,40},{96,40},{96,42},{92,42}}, color={0,127,127}));
    connect(demand.electricPowerDemand, apparentPower.P_el_set) annotation (Line(points={{4.68,100.48},{-34,100.48},{-34,100},{-74,100},{-74,64},{-76,64},{-76,16},{-92,16},{-92,-48},{-56.8,-48},{-56.8,-58.4}}, color={175,0,0}, pattern=LinePattern.Dash));
  else // this time hot water has to be true otherwise the system is not defined
    connect(heatStorage.T_stor_out, dHW_Booster.T_storage_out) annotation (Line(points={{80.2,51.6},{52,51.6},{52,10},{-20,10},{-20,59.2},{-11.52,59.2}}, color={0,0,127}));
    connect(dHW_Booster.electricDemand, demand.electricPowerDemand) annotation (Line(points={{-6.88,63.84},{-6.88,74},{4,74},{4,100.48},{4.68,100.48}}, color={0,0,127}));
    connect(dHW_Booster.hotWaterDemand, demand.hotWaterPowerDemand) annotation (Line(points={{-0.88,63.92},{-0.88,72},{-16,72},{-16,80},{-4,80},{-4,84},{-4.8,84},{-4.8,100.48}}, color={0,0,127}));
    connect(dHW_Booster.electricDemand_households_dhw, apparentPower.P_el_set) annotation (Line(points={{-4.08,47.76},{-4.08,-58},{-40,-58},{-40,-52},{-56.8,-52},{-56.8,-58.4}}, color={0,0,127}));
    connect(dHW_Booster.heatingPowerDemand_Storage, heatStorage.Q_flow_demand) annotation (Line(points={{4.24,56.08},{22,56.08},{22,70},{98,70},{98,42},{92,42}}, color={0,0,127}));
  end if;

  connect(apparentPower.epp, epp) annotation (Line(
      points={{-60,-68},{-60,-66.04},{-80,-66.04},{-80,-98}},
      color={0,127,0},
      thickness=0.5));
  connect(heatStorage.SoC, Controller.SoC) annotation (Line(points={{83.8,51.6},{70,51.6},{70,54},{50,54},{50,8},{-20,8},{-20,-36},{-70,-36},{-70,-22.48},{-61.34,-22.48}}, color={0,0,127}));

  connect(heatStorage.Q_flow_store, add3.y) annotation (Line(
      points={{72.6,42},{74,42},{74,-18},{76,-18},{76,-22},{72.8,-22}},
      color={162,29,33},
      pattern=LinePattern.Dash));
  connect(heatPump.Heat_output, add3.u1) annotation (Line(
      points={{39.76,-4.62},{39.76,-14.5},{54.4,-14.5},{54.4,-17.2}},
      color={162,29,33},
      pattern=LinePattern.Dash));
  connect(heatStorage.T_stor_out, Controller.T) annotation (Line(points={{80.2,51.6},{52,51.6},{52,10},{-66,10},{-66,-10.6},{-61.34,-10.6}}, color={0,0,127}));

  connect(demand.electricPowerDemand, add2.u1) annotation (Line(
      points={{4.68,100.48},{-58,100.48},{-58,59.6},{-56.8,59.6}},
      color={175,0,0},
      pattern=LinePattern.Dash));
  connect(add2.u2, demand.hotWaterPowerDemand) annotation (Line(points={{-47.2,59.6},{-27.6,59.6},{-27.6,100.48},{-4.8,100.48}}, color={0,0,127}));
  connect(add1.u1, demand.heatingPowerDemand) annotation (Line(points={{28.4,60.8},{28.4,80.4},{0,80.4},{0,100.48}}, color={0,0,127}));
  connect(add1.u2, demand.hotWaterPowerDemand) annotation (Line(points={{28.4,51.2},{28.4,77.6},{-4.8,77.6},{-4.8,100.48}}, color={0,0,127}));

  connect(heatPump.epp, epp) annotation (Line(
      points={{35.36,-22},{38,-22},{38,-86},{-80,-86},{-80,-98}},
      color={0,127,0},
      thickness=0.5));
  connect(Tsource.y, Controller.T_source) annotation (Line(points={{-29.2,23},{-24,23},{-24,2},{-46.71,2},{-46.71,-4.77}}, color={0,0,127}));

  connect(heatPump.Q_flow_set, Controller.Q_flow_set_HP) annotation (Line(
      points={{15.34,-16.94},{-12.33,-16.94},{-12.33,-15.11},{-39.45,-15.11}},
      color={175,0,0},
      pattern=LinePattern.Dash));
  connect(gasPortIn, gasBoiler.gasIn) annotation (Line(
      points={{80,-96},{80,-80},{8.2,-80},{8.2,-48}},
      color={255,255,0},
      thickness=1.5));
  connect(gasBoiler.Q_flow_gen, add3.u2) annotation (Line(
      points={{19,-41.2},{48,-41.2},{48,-26.8},{54.4,-26.8}},
      color={175,0,0},
      pattern=LinePattern.Dash));
  connect(Controller.P_set_electricHeater, gasBoiler.Q_flow_set) annotation (Line(
      points={{-39.45,-23.47},{8,-23.47},{8,-28}},
      color={0,135,135},
      pattern=LinePattern.Dash));
  connect(heatingCurve.T_supply, Controller.T_set) annotation (Line(points={{-81.6,-14},{-66,-14},{-66,-16.54},{-61.12,-16.54}}, color={0,0,127}));
  annotation (Icon(graphics={
        Ellipse(
          lineColor={0,125,125},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          extent={{-100,100},{100,-100}}),
        Rectangle(
          extent={{-40,50},{40,-50}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-48,12},{-32,12},{-40,0},{-32,-12},{-48,-12},{-40,0},{-48,12}},
          lineColor={0,0,0},
          smooth=Smooth.None,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-20,58},{20,42}},
          lineColor={0,0,0},
          fillColor={255,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-20,-42},{20,-58}},
          lineColor={0,0,0},
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid),
        Line(
          points={{32,-10},{40,10},{50,-10}},
          color={0,0,0},
          smooth=Smooth.None),
        Ellipse(
          extent={{28,10},{54,-14}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-48,12},{-32,12},{-40,0},{-32,-12},{-48,-12},{-40,0},{-48,12}},
          lineColor={0,0,0},
          smooth=Smooth.None,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Line(
          points={{32,-10},{40,10},{50,-10}},
          color={0,0,0},
          smooth=Smooth.None)}), Documentation(info="<html>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">1. Purpose of model</span></b></p>
<p>Combination of heatpump, electric heater and thermal storage models to be used in the energyConverter.</p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">2. Level of detail, physical effects considered, and physical insight</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(Purely technical component without physical modeling.)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">3. Limits of validity </span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(Purely technical component without physical modeling.)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">4. Interfaces</span></b></p>
<p>TransiEnt.Basics.Interfaces.Combined.HouseholdDemandIn <b>demand</b></p>
<p>TransiEnt.Basics.Interfaces.Electrical.ApparentPowerPort <b>epp - connection to electrical grid</b></p><p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">5. Nomenclature</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">6. Governing Equations</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">7. Remarks for Usage</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">The model contains models for a heat pump, an electric heater, a thermal storage tank and a controller for the operation of the heat pump and the electrical heater. Different control modes can be selected. </span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">8. Validation</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">9. References</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">10. Version History</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">Model created by Anne Hagemeier, Fraunhofer UMSICHT in 2017</span></p>
</html>"));
end HeatPump_Peakboiler;
