﻿within TransiEnt.Consumer.Electrical.Check;
model CheckBatteryElectricVehicleWithControl

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

  extends TransiEnt.Basics.Icons.Checkmodel;

  // _____________________________________________
  //
  //           Instances of other Classes
  // _____________________________________________

  inner TransiEnt.SimCenter simCenter(tableInterpolationSmoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments)
                                      annotation (Placement(transformation(extent={{-90,80},{-70,100}})));

// _____________________________________________
//
//           Functions
// _____________________________________________

  TransiEnt.Components.Boundaries.Electrical.ApparentPower.FrequencyVoltage
                                                               ElectricGrid(
    Use_input_connector_f=false,
    Use_input_connector_v=false,
    v_boundary=400)
    annotation (Placement(transformation(extent={{20,14},{48,-14}})));
  BatteryElectricVehicle bEV(
    inputDataType="SoC",
    C_Bat(displayUnit="J") = 90e3*3600,
    SOCStart=0.5,
    ChargeAtOther=false,
    SOCLimit=1,
    useExternalControl=true,
    vehicleBattery(
      use_PowerRateLimiter=true,
      redeclare model StorageModel = TransiEnt.Storage.Base.GenericStorageHyst (
          use_plantDynamic=true,
          use_inverterEfficiency=true,
          stationaryLossOnlyIfInactive=true),
      StorageModelParams=TransiEnt.Storage.Electrical.Specifications.LithiumIon(
          E_start=bEV.SOCStart*bEV.C_Bat,
          E_max=bEV.C_Bat,
          E_min=1000,
          P_max_unload=bEV.P_max_BEV_drive,
          P_max_load=bEV.P_max_BEV_charge,
          T_plant=5)))
                  annotation (Placement(transformation(extent={{-58,-20},{-18,20}})));
  Modelica.Blocks.Sources.RealExpression
                               GridVoltage1(y=1000)
               annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-88,16})));
  Modelica.Blocks.Sources.Sine sine(
    amplitude=30,
    f=1/(3600),
    offset=230) annotation (Placement(transformation(extent={{-46,52},{-26,72}})));
equation

  // _____________________________________________
  //
  //               Connect Statements
  // _____________________________________________

  connect(bEV.epp, ElectricGrid.epp) annotation (Line(
      points={{-18,0},{-18,-1.77636e-15},{20,-1.77636e-15}},
      color={0,127,0},
      thickness=0.5));

  connect(GridVoltage1.y, bEV.P_limit) annotation (Line(points={{-77,16},{-70,16},{-70,4.6},{-60.2,4.6}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(coordinateSystem(preserveAspectRatio=false)),
  Documentation(info="<html>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">1. Purpose of model</span></b></p>
<p>Test environment for the electric car model.</p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">2. Level of detail, physical effects considered, and physical insight</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">3. Limits of validity </span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">4. Interfaces</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">5. Nomenclature</span></b></p>
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
<p><span style=\"font-family: MS Shell Dlg 2;\">Model created by Dorian Hoeffner, TUHH in November 2021</span></p>
</html>"),
    experiment(
      StopTime=86400,
      Interval=60,
      __Dymola_Algorithm="Dassl"));
end CheckBatteryElectricVehicleWithControl;