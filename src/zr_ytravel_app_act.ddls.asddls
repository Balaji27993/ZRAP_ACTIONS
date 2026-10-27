@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZYTRAVEL_APP_ACT'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_YTRAVEL_APP_ACT
  as select from ytravel_app_act
  association [0..1] to /DMO/I_Agency            as _agency        on $projection.AgencyID = _agency.AgencyID
  association [0..1] to /DMO/I_Customer          as _customer      on $projection.CustomerID = _customer.CustomerID
  association [0..1] to /DMO/I_Overall_Status_VH as _overallstatus on $projection.Status = _overallstatus.OverallStatus
  association [0..1] to I_Currency               as _Currency      on $projection.CurrencyCode = _Currency.Currency

{
  key travel_uuid                  as TravelUUID,
  key travel_id                    as TravelID,
      agency_id                    as AgencyID,
      customer_id                  as CustomerID,
      begin_date                   as BeginDate,
      end_date                     as EndDate,
      description                  as Description,
       status                       as Status,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      booking_fee                  as BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price                  as TotalPrice,
      currency_code                as CurrencyCode,
      @Semantics.user.createdBy: true
      created_by                   as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                   as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      last_chnaged_by              as LastChnagedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_chnaged_at              as LastChnagedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      local_last_chnaged           as LocalLastChnaged,

      --exposed associations
      _agency,
      _customer,
      _overallstatus,
      _Currency

}
