@EndUserText.label: 'F4 help for popup'
define abstract entity Zabstract_entity

{

  @EndUserText.label: 'Modity Status'
  @Consumption.valueHelpDefinition: [{ 
                 entity : { name : '/DMO/I_Overall_Status_VH', element: 'OverallStatus' }
                                    }]
    status : /dmo/travel_status;
    
}
