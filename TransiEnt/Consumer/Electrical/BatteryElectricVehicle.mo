within TransiEnt.Consumer.Electrical;
model BatteryElectricVehicle "Electricity consumption of a home wallbox"

//________________________________________________________________________________//
// Component of the TransiEnt Library, version: 2.0.2                             //
//                                                                                //
// Licensed by Hamburg University of Technology under the 3-BSD-clause.           //
// Copyright 2021, Hamburg University of Technology.                              //
//________________________________________________________________________________//
//                                                                                //
// TransiEnt.EE, ResiliEntEE, IntegraNet and IntegraNet II are research projects  //
// supported by the German Federal Ministry of Economics and Energy               //
// (FKZ 03ET4003, 03ET4048, 0324027 f 03EI1008).                                //
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
  extends TransiEnt.Basics.Icons.Model;

  // _____________________________________________
  //
  //              Parameters
  // _____________________________________________

  parameter String inputDataType="Distance" "Choose data type format: 'Distance travelled' or 'SoC at the arrival back home'"
    annotation (Dialog(group="Data"), choices(__Dymola_radioButtons=true,
                choice="Distance",
                choice="SoC"));
  parameter Real vehicleEfficiency=18  "[kWh/100km] Average electricity use per kilometer"    annotation (Dialog(group=
          "Electric Vehicle", enable=inputDataType == "Distance"));

  parameter SI.Power P_max_BEV_drive(displayUnit="kW")=200000 "Maximum driving power"  annotation (Dialog(group=
          "Electric Vehicle"));

  parameter SI.Power P_max_BEV_charge(displayUnit="kW")=22000 "Maximum charging power" annotation (Dialog(group=
          "Electric Vehicle"));

  parameter SI.Energy C_Bat(displayUnit="kWh")=252000000 "Battery capacity"  annotation (Dialog(group=
          "Electric Vehicle"));

  parameter Real SOCStart=0.7 "Battery state of charge at the start of the simulation" annotation (Dialog(group="Electric Vehicle"));

  parameter Integer column=1 "Table column set for vehicle and location data" annotation (Dialog(group="Data",
        enable=inputDataType == "Distance"));

  parameter Modelica.Units.SI.Power P_chargingStation(displayUnit="kW") = 11000 "Charging power of the home charging station" annotation (Dialog(group="Charging station"));

  parameter SI.Power P_work(displayUnit="kW") = 0 "Charging power of the charging station at work" annotation (Dialog(group="Charging station", enable=
          inputDataType == "Distance"));

  parameter SI.Power P_public(displayUnit="kW") = 0 "Charging power of public charging stations" annotation (Dialog(group="Charging station", enable=inputDataType == "Distance"));

  parameter Modelica.Units.SI.Power P_fast(displayUnit="kW")=0 "Charging power of fast charging" annotation (Dialog(group="Charging station", enable=inputDataType == "Distance"));

  parameter Modelica.Units.SI.Power P_superfast(displayUnit="kW")=0 "Charging power of superfast charging" annotation (Dialog(group="Charging station", enable=inputDataType == "Distance"));

  parameter Real SOCLimit=1 "Maximum battery level"  annotation (Dialog(group="Charging station"));

  parameter Boolean useExternalControl = false "Checkbox to enable external load control"  annotation (
      Evaluate=true,
      HideResult=true,
      choices(checkBox=true),
      Dialog(group="Load Management"));

  parameter String controlType = "limit" "Load control method" annotation (
       Dialog(enable=useExternalControl, group="Load Management"),
       choices(choice="limit",
               choice="proportional"));


  // _____________________________________________
  //
  //              Variables
  // _____________________________________________


  Real SoC=vehicleBattery.SOC.y;
  // _____________________________________________
  //
  //              Complex Components
  // _____________________________________________

  TransiEnt.Components.Boundaries.Electrical.ApparentPower.ApparentPower powerToGrid(
    useInputConnectorQ=false,
    Q_el_set_const=0,
    useCosPhi=false)
    annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=180,
        origin={62,-78})));

  TransiEnt.Storage.Electrical.LithiumIonBattery vehicleBattery(
                                StorageModelParams=TransiEnt.Storage.Electrical.Specifications.LithiumIon(
        E_start=SOCStart*C_Bat,
        E_max=C_Bat,
        E_min=10000,
        P_max_unload=P_max_BEV_drive,
        P_max_load=P_max_BEV_charge,
        T_plant=5))    annotation (Placement(transformation(extent={{76,-22},{40,14}})));


  Modelica.Blocks.Sources.RealExpression P_batteryToGrid(y=if noEvent(
        P_set_battery.u2) then -vehiclePowerBoundary.epp.P else 0)
                                               annotation (Placement(transformation(extent={{2,-66},{54,-42}})));
  TransiEnt.Components.Boundaries.Electrical.ActivePower.Frequency vehiclePowerBoundary(
      useInputConnector=false) annotation (Placement(transformation(extent={{26,4},{10,-12}})));

  Modelica.Blocks.Math.Min min1 if useExternalControl and controlType == "limit"  annotation (Placement(transformation(extent={{-64,-22},{-50,-8}})));

  Modelica.Blocks.Math.Product product1 if  useExternalControl and controlType == "proportional" annotation (Placement(transformation(extent={{-66,-48},{-52,-34}})));

  Modelica.Blocks.Logical.Switch P_set_battery  annotation (Placement(transformation(extent={{54,62},{72,44}})));


  Modelica.Blocks.Sources.RealExpression drivingPower(y=-vehicleEfficiency/100*DistanceLocationData.y[1]/DistanceLocationData.r*3600) if
                                                                                                                      inputDataType=="Distance" annotation (Placement(transformation(extent={{46,70},
            {76,90}})));

  Modelica.Blocks.Sources.BooleanExpression presence(y=vehicleHome.y) if inputDataType=="Distance" annotation (Placement(transformation(extent={{4,44},{24,60}})));

  Modelica.Blocks.Sources.RealExpression zero(y=0) if inputDataType=="SoC"   annotation (Placement(transformation(extent={{46,84},{76,104}})));

  Modelica.Blocks.Sources.RealExpression derLoc(y=if DistanceLocationData.smoothness == Modelica.Blocks.Types.Smoothness.ConstantSegments then 0 else der(DistanceLocationData.y[2])) if                                                                           inputDataType=="Distance"
    annotation (Placement(transformation(extent={{-56,-102},{-28,-82}})));
  Modelica.Blocks.Sources.BooleanExpression vehicleHome(y=abs(1 - DistanceLocationData.y[2]) <
        0.5 and (abs(derLoc.y) < 0.01)) if inputDataType=="Distance"
    annotation (Placement(transformation(extent={{-56,-84},{-28,-68}})));
  Modelica.Blocks.Logical.Hysteresis hysteresis(uLow=SOCLimit - 0.005,uHigh=
        SOCLimit)
    annotation (Placement(transformation(extent={{-50,72},{-34,88}})));
  Modelica.Blocks.Sources.RealExpression soC(y=SoC)
    annotation (Placement(transformation(extent={{-76,72},{-58,88}})));
  Modelica.Blocks.Logical.Switch P_charge_SoC annotation (Placement(transformation(extent={{0,72},{16,88}})));

  Modelica.Blocks.Sources.RealExpression zero1(y=0)
    annotation (Placement(transformation(extent={{-28,80},{-14,94}})));
  Modelica.Blocks.Sources.RealExpression P_home(y=if vehicleHome.y then P_chargingStation else 0) if inputDataType=="Distance" annotation (Placement(transformation(extent={{-94,12},{-66,32}})));

  Modelica.Blocks.Sources.RealExpression P_other(y=if (abs(2 - DistanceLocationData.y[2]) < 0.5 and (abs(derLoc.y) < 0.01)) then P_work elseif (abs(3 - DistanceLocationData.y[2]) < 0.5 and (abs(derLoc.y) < 0.01))
         then P_public elseif (abs(4 - DistanceLocationData.y[2]) < 0.5 and (abs(derLoc.y) < 0.01)) then P_fast elseif (abs(5 - DistanceLocationData.y[2]) < 0.5 and (abs(derLoc.y) < 0.01)) then P_superfast else 0) if inputDataType=="Distance"
    annotation (Placement(transformation(extent={{-94,26},{-66,44}})));
  Modelica.Blocks.Math.Add add if inputDataType=="Distance"  annotation (Placement(transformation(extent={{-30,-30},{-16,-16}})));

  Modelica.Blocks.Sources.RealExpression P_charge(y=P_chargingStation) if inputDataType=="SoC" annotation (Placement(transformation(extent={{-94,38},{-66,54}})));

  //Data tables

   replaceable model DistanceLocationTable = TransiEnt.Basics.Tables.ElectricGrid.Electromobility.DistanceLocationProfiles_family_15min    constrainedby
    TransiEnt.Basics.Tables.ElectricGrid.Electromobility.Base.DistanceLocationTable(multiple_outputs=true, columns={column + 1, column+2}) "Data table for data time series of distance travelled" annotation (choicesAllMatching=true,Dialog(group="Data",
        enable=inputDataType == "Distance"));
     DistanceLocationTable DistanceLocationData if  inputDataType=="Distance" annotation (Placement(transformation(extent={{-94,-90},{-80,-76}})));

   replaceable model soCTable = TransiEnt.Basics.Tables.ElectricGrid.Electromobility.SoCTable constrainedby TransiEnt.Basics.Tables.ElectricGrid.Electromobility.Base.SoCTable(
                                                                       multiple_outputs=true) "Data table for data time series of battery SoC" annotation (choicesAllMatching=true,Dialog(group="Data",
        enable=inputDataType == "SoC"));
   soCTable soC_data if inputDataType=="SoC" annotation (Placement(transformation(extent={{8,28},{20,40}})));


  // _____________________________________________
  //
  //              Interfaces
  // _____________________________________________

  Modelica.Blocks.Interfaces.RealInput P_limit if useExternalControl and controlType == "limit"  "Interface for Load Regulation" annotation (Placement(transformation(extent={{-128,-24},{-90,14}}),
                        iconTransformation(extent={{-128,-24},{-90,14}})));
  Modelica.Blocks.Interfaces.RealInput p_control if useExternalControl and controlType == "proportional" "Interface for Load Regulation" annotation (Placement(transformation(extent={{-128,-58},
            {-90,-20}}),    iconTransformation(extent={{-128,-58},{-90,-20}})));
  TransiEnt.Basics.Interfaces.Electrical.ApparentPowerPort epp annotation (Placement(transformation(extent={{90,-10},{110,10}})));
  Modelica.Blocks.Interfaces.RealInput SoC_consumption_internal;


equation

  //equations for input type Soc

  if inputDataType=="SoC" then
    when P_set_battery.u2 then
    reinit(vehicleBattery.storageModel.E, max(vehicleBattery.storageModel.SOC - SoC_consumption_internal, 0)*(vehicleBattery.StorageModelParams.E_max
       - vehicleBattery.StorageModelParams.E_min) + vehicleBattery.StorageModelParams.E_min);
    end when;
  end if;

  //equations for input type Distance
    if inputDataType=="Distance" then
     SoC_consumption_internal=0;
    end if;


  //connect statements
  connect(vehiclePowerBoundary.epp, vehicleBattery.epp) annotation (Line(
      points={{26,-4},{40,-4}},
      color={0,135,135},
      thickness=0.5));
  connect(powerToGrid.epp, epp) annotation (Line(
      points={{72,-78},{86,-78},{86,0},{100,0}},
      color={0,127,0},
      thickness=0.5));
  connect(P_batteryToGrid.y, powerToGrid.P_el_set) annotation (Line(points={{56.6,-54},{68,-54},{68,-66}}, color={0,0,127}));
  connect(p_control, product1.u2) annotation (Line(points={{-109,-39},{-86,-39},{-86,-45.2},{-67.4,-45.2}}, color={0,0,127}));
  connect(P_set_battery.y, vehicleBattery.P_set) annotation (Line(points={{72.9,53},{80,53},{80,28},{58,28},{58,12.92}},
                                               color={0,0,127}));
  connect(drivingPower.y, P_set_battery.u3) annotation (Line(points={{77.5,80},{86,80},{86,68},{52.2,68},{52.2,60.2}},
                                    color={0,0,127}));
  connect(zero.y, P_set_battery.u3) annotation (Line(points={{77.5,94},{88,94},{88,68},{52.2,68},{52.2,60.2}},
                                                     color={0,0,127}));
  connect(soC_data.isConnected, P_set_battery.u2) annotation (Line(points={{19.4,36.4},{32,36.4},{32,52},{42,52},{42,53},{52.2,53}},
                                                               color={255,0,255}));
  connect(SoC_consumption_internal,soC_data.SoC_consumption);
  connect(soC.y, hysteresis.u)    annotation (Line(points={{-57.1,80},{-56,80},{-56,82},{-54,82},{-54,78},{-51.6,78}},
                                                     color={0,0,127}));
  connect(hysteresis.y, P_charge_SoC.u2) annotation (Line(points={{-33.2,80},{-26,80},{-26,78},{-1.6,78}},
                                                                                          color={255,0,255}));
  connect(P_charge_SoC.u1, zero1.y) annotation (Line(points={{-1.6,86.4},{-8,86.4},{-8,87},{-13.3,87}},        color={0,0,127}));
  connect(presence.y, P_set_battery.u2) annotation (Line(points={{25,52},{52.2,52},{52.2,53}},      color={255,0,255}));
  connect(P_charge_SoC.y, P_set_battery.u1) annotation (Line(points={{16.8,80},{40,80},{40,46},{52.2,46},{52.2,45.8}},
                                                                                                       color={0,0,127}));
  connect(P_home.y, product1.u1) annotation (Line(points={{-64.6,22},{-64.6,-32},{-67.4,-32},{-67.4,-36.8}},              color={0,0,127}));
  connect(min1.y, add.u2) annotation (Line(points={{-49.3,-15},{-44,-15},{-44,-27.2},{-31.4,-27.2}},
                                                                                                 color={0,0,127}));
  connect(product1.y, add.u2) annotation (Line(points={{-51.3,-41},{-44,-41},{-44,-27.2},{-31.4,-27.2}},
                                                                                                     color={0,0,127}));
  connect(P_other.y, add.u1) annotation (Line(points={{-64.6,35},{-36,35},{-36,-18.8},{-31.4,-18.8}},                 color={0,0,127}));
    if not useExternalControl then
  connect(P_home.y, add.u2) annotation (Line(points={{-64.6,22},{-64.6,-27.2},{-31.4,-27.2}},                        color={0,0,127}));
    end if;
  connect(add.y, P_charge_SoC.u3) annotation (Line(points={{-15.3,-23},{-12,-23},{-12,73.6},{-1.6,73.6}},          color={0,0,127}));
  connect(p_control, P_charge_SoC.u3) annotation (Line(points={{-109,-39},{-88,-39},{-88,-52},{-12,-52},{-12,73.6},{-1.6,73.6}},                             color={0,0,127}));
  connect(P_limit, min1.u2) annotation (Line(points={{-109,-5},{-72,-5},{-72,-19.2},{-65.4,-19.2}},
                                                                                                  color={0,0,127}));
  connect(P_home.y, min1.u1) annotation (Line(points={{-64.6,22},{-64.6,-10.8},{-65.4,-10.8}},                                        color={0,0,127}));
  connect(P_charge.y, P_charge_SoC.u3) annotation (Line(points={{-64.6,46},{-12,46},{-12,73.6},{-1.6,73.6}}, color={0,0,127}));
  annotation (
      Diagram(graphics={
        Line(
          points={{-58,-78}},
          color={28,108,200},
          pattern=LinePattern.Dot),
        Line(
          points={{18,-12},{18,-10},{18,-14},{18,-22},{18,-46}},
          color={0,0,0},
          pattern=LinePattern.Dot,
          arrow={Arrow.None,Arrow.Filled}),
        Rectangle(
          extent={{-86,98},{26,68}},
          lineColor={28,108,200},
          pattern=LinePattern.Dash),
        Text(
          extent={{-82,98},{-52,90}},
          textColor={28,108,200},
          textString="SoC Limit"),
        Rectangle(
          extent={{-98,64},{-58,16}},
          lineColor={28,108,200},
          pattern=LinePattern.Dash),
        Text(
          extent={{-94,64},{-64,54}},
          textColor={28,108,200},
          textString="P_charge"),
        Rectangle(
          extent={{-126,12},{-10,-60}},
          lineColor={28,108,200},
          pattern=LinePattern.Dash),
        Text(
          extent={{-120,-52},{-90,-60}},
          textColor={28,108,200},
          textString="Load control")}),
    Icon(graphics={
        Line(points={{20,-28}}, color={0,0,0}),
        Polygon(
          points={{-66,2},{60,2},{72,-28},{-80,-28},{-66,2}},
          lineColor={238,46,47},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{14,-14},{42,-42}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-56,-14},{-28,-42}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-40,34},{36,34},{50,0},{-54,0},{-40,34}},
          lineColor={238,46,47},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{50,-8},{54,-12}},
          lineColor={0,0,0},
          lineThickness=1,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Line(
          points={{52,-10},{60,-12},{66,-10},{70,-4},{74,0},{84,0},{92,-4},{100,
              0},{96,-2}},
          color={0,140,72},
          thickness=1)}),
    experiment(StopTime=0, __Dymola_Algorithm="Dassl"),
    Documentation(info="<html>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">1. Purpose of model</span></b></p>
<p>Simple model of an electric vehicle battery. Table-based profiles of the vehicle location and the kilometers driven determine the state-of-charge of the vehicle. When the vehicle ist home, it will charge from the grid. It can be selected wheather charging will occur only at home or also at other places, thus affecting the state-of-charge. </p>
<p>The wall box charging power can be externally controlled by reducing the charging power proportionally or by setting a fixed maximum charging power. Load control will only affect the charging power at home, not at any other charging station.</p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">2. Level of detail, physical effects considered, and physical insight</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">3. Limits of validity </span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">4. Interfaces</span></b></p>
<p>epp: apparent power port</p>
<p>optional: RealInput P_limit or p_control for external load management.</p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">5. Nomenclature</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">6. Governing Equations</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">Both can be set: the maximum charging power of the electric vehicle and the maximum charging power of the charging station. Charging power will be the minimum of those two values.</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">7. Remarks for Usage</span></b></p>
<p>The data table have to be prepared in preprocessing and will usually contain information about charging power, average driving electricity consumption and battery capacity. If parameters in the model are chosen differently, it might come to situations where battery capacity is not sufficient for the driving range and thus less driving power is used than specified in the table.</p>
<p>Since the battery is rarely completely discharged, cases like this are very rare. </p>
<p><br><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">8. Validation</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">9. References</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">10. Version History</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">Model created by Dorian H&ouml;ffner, Fraunhofer UMSICHT in December 2021</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">Model modified by Anne Hagemeier, Fraunhofer UMSICHT, in June 2022</span></p>
</html>"));
end BatteryElectricVehicle;
