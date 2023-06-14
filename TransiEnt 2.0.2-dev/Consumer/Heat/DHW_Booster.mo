within TransiEnt.Consumer.Heat;
model DHW_Booster "Provides remaining electrical heating power for the desired temperature level for domestic hot water supply."

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

  // Mal überlegen

  Modelica.Blocks.Interfaces.RealOutput electricPower "Connector of Real output signal" annotation (Placement(transformation(
        extent={{-17,-17},{17,17}},
        rotation=270,
        origin={-1,-111}), iconTransformation(extent={{-17,-17},{17,17}},
        rotation=270,
        origin={-1,-103})));
  Modelica.Blocks.Interfaces.RealOutput heatingPowerDemand_Storage "Connector of Real output signal" annotation (Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={112,0}),  iconTransformation(
        extent={{-17,-17},{17,17}},
        rotation=0,
        origin={103,1})));

  Modelica.Blocks.Interfaces.RealInput hotWaterDemand "Connector of Real input signal 2" annotation (Placement(transformation(
        extent={{-17,-17},{17,17}},
        rotation=270,
        origin={41,103}), iconTransformation(extent={{-17,-17},{17,17}},
        rotation=270,
        origin={39,99})));
  Modelica.Blocks.Interfaces.RealInput electricDemand "Connector of Real input signal 1" annotation (Placement(transformation(
        extent={{18,-18},{-18,18}},
        rotation=90,
        origin={-40,106}), iconTransformation(extent={{18,-18},{-18,18}},
        rotation=90,
        origin={-36,98})));

  // _____________________________________________
  //
  //          Parameters
  // _____________________________________________

  parameter Modelica.Units.SI.Temperature T_dhw = 50 + 273.15 "Temperature of domestic hot water supply";
  parameter Modelica.Units.SI.Temperature T_freshWater = 15 + 273.15 "Temperature of fresh Water";
  parameter Modelica.Units.SI.HeatCapacity cp = 4190 "Heat Capacity Water"; // We should consider using the fluid data from SimCenter

  // _____________________________________________
  //
  //                   Variables
  // _____________________________________________

  Modelica.Units.SI.MassFlowRate massflow_dhw "Massflowrate of domestic hot water supply";
  TransiEnt.Basics.Interfaces.General.TemperatureIn T_storage_out annotation (Placement(transformation(extent={{-17,-17},{17,17}}, origin={-103,1}),
                                                                                                                                      iconTransformation(extent={{-114,20},{-74,60}})));

equation

  massflow_dhw = hotWaterDemand / (cp * (T_dhw - T_freshWater));
  heatingPowerDemand_Storage = massflow_dhw * cp * (T_storage_out - T_freshWater);

  if T_dhw > T_storage_out then // No issues during testing but a noEvent-operator might be necessary in the future
    electricPower = massflow_dhw * cp * (T_dhw - T_storage_out);
  else
    electricPower = 0;
  end if;

  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(coordinateSystem(preserveAspectRatio=false)));
end DHW_Booster;
