@EndUserText.label: 'F4 help for popup'
define abstract entity ZABSTRACT_F4

{
  @EndUserText.label: 'Modity Status'
  @Consumption.valueHelpDefinition: [{ 
                 entity : { name : 'ZVALUEHELP', element: 'OverallStatus' }
                                    }]
    status : /dmo/travel_status;
    
}
