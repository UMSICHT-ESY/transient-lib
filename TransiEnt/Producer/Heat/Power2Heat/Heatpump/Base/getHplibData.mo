within TransiEnt.Producer.Heat.Power2Heat.Heatpump.Base;
function getHplibData "function to get the regression parameters of the the hplib heat pump models"

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

  input TransiEnt.Components.Electrical.Grid.Characteristics.LVCabletypes heatpump_type "type of low voltage cable";
  output Real hplib_data[4] "returns cable data. [r1,x1,c1,ir]";
algorithm
  // saved heat pump data
  // Data p1_cop, p2_cop, p3_cop, p4_cop, p1_P_el_h, p2_P_el_h, p3_P_el_h, p4_P_el_h
  // hplib_data:={p1_cop, p2_cop, p3_cop, p4_cop, p1_P_el_h, p2_P_el_h, p3_P_el_h, p4_P_el_h};
  if heatpump_type == TransiEnt.Producer.Heat.Power2Heat.Heatpump.Base.HeatpumpTypes.H1 then
    hplib_data:={61.321266, -0.093088378,  7.3470523, -61.17143, 47.9145, 0.01238278, 0.00798229, -47.9618};

  elseif heatpump_type == TransiEnt.Producer.Heat.Power2Heat.Heatpump.Base.HeatpumpTypes.H2 then
    hplib_data:={57.527917, -0.059697, 5.66823, -57.433, 39.0022, 0.012576, 0.36227339, -38.998969};

  elseif heatpump_type == TransiEnt.Producer.Heat.Power2Heat.Heatpump.Base.HeatpumpTypes.H3 then
    hplib_data:={0.094498947, -0.0944989, 7.9292228, 0.002788, -0.013182, 0.013182, 0.0386469, -0.0369743};

  elseif heatpump_type == TransiEnt.Producer.Heat.Power2Heat.Heatpump.Base.HeatpumpTypes.H4 then
    hplib_data:={0.10565139, -0.10565, 8.21271978, -0.0306546, -0.01540968, 0.01540968, 0.2314071, 0.0044696};

  else

  end if;
end getHplibData;
