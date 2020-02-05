/*
-----------------------------------
--OC Recibidas sin facturar
-----------------------------------
        select pv.vendor_id,pv.vendor_name proveedor,
        msi.inventory_item_id,
msi.segment1 mp,
'NO' consignacion,
 pll.country_of_origin_code,
(select territory_short_name from apps.FND_TERRITORIES_VL@lnkapxtcom ft
where pll.country_of_origin_code = ft.territory_code) origen,
DECODE(NVL(ph.attribute9,'N'), 
  'N',pll.PROMISED_DATE, 
  pll.PROMISED_DATE+NVL( 
  (select transit_time from apx_tcom.tc_vendor_shipment_data@lnkapxtcom tvs where vendor_id = ph.vendor_id
   and tvs.vendor_site_id = ph.vendor_site_id and country_of_origin_code= pll.country_of_origin_code),0)) fecha_arribo,
quantity_received-quantity_billed cantidad,
DECODE(ph.currency_code,'ARS',pl.unit_price,pl.unit_price*apps.ap_utilities_pkg.get_exchange_rate@lnkapxtcom(ph.currency_code,'ARS','Corporate',trunc(sysdate),'SQL')) precio_unitario,
at.term_id, at.name termino,
DECODE(NVL(ph.attribute9,'N'), 
  'N',pll.PROMISED_DATE, 
  pll.PROMISED_DATE+NVL( 
  (select transit_time from apx_tcom.tc_vendor_shipment_data@lnkapxtcom tvs where vendor_id = ph.vendor_id
   and tvs.vendor_site_id = ph.vendor_site_id and country_of_origin_code= pll.country_of_origin_code),0))  fecha_pago_derechos_imp
from apps.mtl_system_items_b@lnkapxtcom msi,
apps.po_vendors@lnkapxtcom pv,
apps.po_line_locations_all@lnkapxtcom pll,
apps.po_headers_all@lnkapxtcom ph,
apps.po_lines_all@lnkapxtcom pl,
apps.ap_terms_tl@lnkapxtcom at
where msi.inventory_item_id=pl.item_id
and at.language='ESA'
and ph.po_header_id=pl.po_header_id
and pl.po_line_id=pll.po_line_id
and pll.po_header_id = ph.po_header_id
and msi.organization_id = 13510
and ph.vendor_id=pv.vendor_id
and NVL(pll.closed_code,'OPEN') NOT IN ('CLOSED','FINALLY CLOSED')
and NVL(pll.cancel_flag,'N')='N'
and NVL(ph.approved_flag,'N')='Y'
and ph.terms_id=at.term_id
and pll.quantity_received > pll.quantity_billed
order by origen 


-----------------------------------
--Facturas pendientes de pago
-----------------------------------
select  pv.vendor_id id_proveedor,
at.name termino,
aps.due_date fecha_pago,
aps.gross_amount importe_pago
from 
apps.po_vendors@lnkapxtcom pv,
apps.ap_terms_tl@lnkapxtcom at,
apps.ap_invoices_all@lnkapxtcom ai,
apps.AP_PAYMENT_SCHEDULES_all@lnkapxtcom aps
where at.language='ESA'
and ai.vendor_id=pv.vendor_id
and ai.terms_id=at.term_id
and NVL(ai.payment_status_flag,'N') <>'Y'
and ai.org_id=86
and ai.invoice_id=aps.invoice_id
and aps.amount_remaining<>0
and ai.invoice_id in(
select aid.invoice_id
from apps.ap_invoice_distributions_all@lnkapxtcom aid
where po_distribution_id is not null
and aid.invoice_id=ai.invoice_id)

*/