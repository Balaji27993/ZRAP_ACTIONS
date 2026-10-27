@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZYTRAVEL_APP_ACT',
  semanticKey: [ 'TravelUUID' ] }
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_YTRAVEL_APP_ACT
  provider contract transactional_query
  as projection on ZR_YTRAVEL_APP_ACT
  association [1..1] to ZR_YTRAVEL_APP_ACT as _BaseEntity on  $projection.TravelUUID = _BaseEntity.TravelUUID
                                                          and $projection.TravelID   = _BaseEntity.TravelID
{
  key TravelUUID,
  key TravelID,
      @Consumption.valueHelpDefinition: [ { entity: { name: '/DMO/I_Agency',
                                                   element: 'AgencyID' } } ]
      AgencyID,
      @Consumption.valueHelpDefinition: [ { entity: { name: '/DMO/I_Customer',
                                                   element: 'CustomerID' } } ]
      CustomerID,
      BeginDate,
      EndDate,
      Description,
     // @ObjectModel.text.element: [ '' ]
         @Consumption.valueHelpDefinition: [{
                                          entity :{ name: '/DMO/I_Overall_Status_VH' ,
                                          element: 'OverallStatus'}  }]
       Status,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_Currency',
                                                     element: 'Currency' } } ]
      CurrencyCode,
      @Semantics: {
        user.createdBy: true
      }
      CreatedBy,
      @Semantics: {
        systemDateTime.createdAt: true
      }
      CreatedAt,
      @Semantics: {
        user.localInstanceLastChangedBy: true
      }
      LastChnagedBy,
      @Semantics: {
        systemDateTime.localInstanceLastChangedAt: true
      }
      LastChnagedAt,
      @Semantics: {
        systemDateTime.lastChangedAt: true
      }
      LocalLastChnaged,
      _BaseEntity,
      --exposed associations
      _agency,
      _customer,
      _overallstatus,
      _Currency
     
}
