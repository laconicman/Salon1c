#!/usr/bin/env bash
# apply-patches.sh — regenerate Sources/Salon1cAPI/openapi.yaml from the vendored
# vendor OpenAPI document (api_salon1c.yaml, kept verbatim).
#
# Each numbered patch (P-n) is declared in SpecOwnership.md — keep the two in
# sync. Run:  Upstream/salon1c-openapi/apply-patches.sh
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
SRC="$HERE/api_salon1c.yaml"
PATCHES="$HERE/patches"
OUT="$ROOT/Sources/Salon1cAPI/openapi.yaml"
WORK="$(mktemp -t salon1c-spec)"
trap 'rm -f "$WORK"' EXIT
cp "$SRC" "$WORK"

opid() { # $1 path  $2 method  $3 new operationId
  yq -i ".paths.\"$1\".$2.operationId = \"$3\"" "$WORK"
}

jsonparam() { # $1 path  $2 method  $3 param name  $4 fragment file (schema)
  yq -i "(.paths.\"$1\".$2.parameters[] | select(.name == \"$3\")).content.\"application/json\".schema = load(\"$PATCHES/$4\")" "$WORK"
  yq -i "del((.paths.\"$1\".$2.parameters[] | select(.name == \"$3\")).schema)" "$WORK"
}

# P1 — operationId curation. Vendor ids are raw slugs and collide across API
# versions (book_services and book_staff each name a v1 and a v2 operation);
# the generator requires unique ids. New ids also keep the published API
# surface stable.
opid '/hs/api/v1/auth_types/{salon_id}/'        get    getAuthTypes
opid '/hs/api/v1/auth/{salon_id}/'              post   authorize
opid '/hs/api/v1/validity_usertoken/{salon_id}/' post  checkUserToken
opid '/hs/api/v1/private_auth/{salon_id}/'      post   authorizeWithSignature
opid '/hs/api/v1/auth_request/{salon_id}'       post   requestPhoneConfirmation
opid '/hs/api/v1/auth_token/{salon_id}'         post   getClientToken
opid '/hs/api/v1/book_services/{salon_id}/'     get    getBookableServices
opid '/hs/api/v1/book_staff/{salon_id}/'        get    getBookableStaff
opid '/hs/api/v1/book_dates/{salon_id}/'        get    getBookableDates
opid '/hs/api/v1/book_times/{salon_id}/'        get    getBookableTimes
opid '/hs/api/v1/recording_dates/{salon_id}/'   get    getRecordingDates
opid '/hs/api/v1/book_record/{salon_id}/'       post   bookVisit
opid '/hs/api/v1/change_record/{salon_id}/'     put    rescheduleVisit
opid '/hs/api/v1/cancel_record/{salon_id}/'     delete cancelVisit
opid '/hs/api/v1/record_cost/{salon_id}/'       get    getRecordCost
opid '/hs/api/v1/finished_visites/{salon_id}/'  get    getFinishedVisits
opid '/hs/api/v1/visites/{salon_id}/'           get    getVisits
opid '/hs/api/v1/debt_visits/{salon_id}'        get    getDebtVisits
opid '/hs/api/v1/visit_payment/{salon_id}/'     post   payVisit
opid '/hs/api/v1/client/{salon_id}/'            get    getClientInfo
opid '/hs/api/v1/client/{salon_id}/'            post   createClient
opid '/hs/api/v1/client/{salon_id}/'            put    updateClientById
opid '/hs/api/v1/clients/{salon_id}/'           post   searchClients
opid '/hs/api/v1/deposit_list/{salon_id}/'      get    getClientAccounts
opid '/hs/api/v1/update_client/{salon_id}'      post   updateClientProfile
opid '/hs/api/v1/refill_deposit/{salon_id}'     post   refillDeposit
opid '/hs/api/v1/records_history/{salon_id}/'   get    getClientVisitHistory
opid '/hs/api/v1/records/{salon_id}/'           get    getClientPlannedVisits
opid '/hs/api/v1/records/{salon_id}/'           put    updateRecord
opid '/hs/api/v1/tickets/{salon_id}'            get    getClientTickets
opid '/hs/api/v1/ticket/{salon_id}/'            get    getClientTicket
opid '/hs/api/v1/certificates/{salon_id}'       get    getClientCertificates
opid '/hs/api/v1/salons/{salon_id}/'            get    getSalons
opid '/hs/api/v1/records_list/{salon_id}/'      get    getRecordsList
opid '/hs/api/v1/services/{salon_id}/'          get    getServices
opid '/hs/api/v1/record_rating/{salon_id}'      post   rateVisit
opid '/hs/api/v1/comments/{salon_id}/'          get    getComments
opid '/hs/api/v1/price_list/{salon_id}/'        get    getPriceList
opid '/hs/api/v1/cart_cost/{salon_id}/'         get    getCartCost
opid '/hs/api/v1/payment/{salon_id}'            post   payOrder
opid '/hs/api/v1/payment/{salon_id}'            delete cancelPayment
opid '/hs/api/v1/group_list/{salon_id}'         get    getProductGroups
opid '/hs/api/v1/contact_information/{salon_id}' get   getStoreContacts
opid '/hs/api/v1/public_offer/{salon_id}'       get    getPublicOffer
opid '/hs/api/v1/privacy_policy/{salon_id}'     get    getPrivacyPolicy
opid '/hs/api/v1/order_list/{salon_id}/'        get    getOrders
opid '/hs/api/v1/order_status_list/{salon_id}'  get    getOrderStatuses
opid '/hs/api/v1/deposit_detail/{salon_id}/'    get    getDepositMovements
opid '/hs/api/v1/delivery_list/{salon_id}'      get    getDeliveryOptions
opid '/hs/api/v1/filter_list/{salon_id}'        get    getProductFilters
opid '/hs/api/v2/book_staff/'                   get    getTerminalStaff
opid '/hs/api/v2/book_services/'                get    getTerminalServices
opid '/hs/api/v2/find_client_by_phone/'         get    findClientByPhone
opid '/hs/api/v2/auth'                          post   authorizeTerminal
opid '/hs/api/v2/cart_cost/'                    get    getTerminalCartCost
opid '/hs/api/v2/payment'                       post   payTerminal
opid '/hs/api/v1/sale/{salon_id}/'              post   createSale
opid '/hs/api/v1/sale/{salon_id}/'              put    updateSale
opid '/hs/api/v1/sale/{salon_id}/'              delete cancelSale
opid '/hs/api/v1/payment_link/{salon_id}/'      post   createPaymentLink
opid '/hs/api/v1/work_schedule/{salon_id}/'     get    getStaffWorkSchedule
opid '/hs/api/v1/work_schedule/{salon_id}/'     put    updateStaffWorkSchedule

# P2 — JSON-in-query parameters. The vendor types every «Строка Json»
# parameter as `type: string`; the string is a serialized JSON document, so
# these are re-typed as `content: application/json` with the schemas under
# patches/ — the generator then emits typed arguments and does the JSON
# encoding itself. The vendor's parameter descriptions are kept verbatim.
jsonparam '/hs/api/v1/book_services/{salon_id}/' get service_ids service_ids.schema.yaml
jsonparam '/hs/api/v1/book_staff/{salon_id}/'    get service_ids service_ids.schema.yaml
jsonparam '/hs/api/v1/book_dates/{salon_id}/'    get service_ids service_ids.schema.yaml
jsonparam '/hs/api/v1/book_times/{salon_id}/'    get service_ids service_ids.schema.yaml
jsonparam '/hs/api/v1/record_cost/{salon_id}/'   get record_array record_array.schema.yaml
jsonparam '/hs/api/v1/price_list/{salon_id}/'    get product_id  product_id.schema.yaml
jsonparam '/hs/api/v1/price_list/{salon_id}/'    get filters     filters.schema.yaml
jsonparam '/hs/api/v1/cart_cost/{salon_id}/'     get cart        cart.schema.yaml
jsonparam '/hs/api/v1/cart_cost/{salon_id}/'     get delivery    delivery.schema.yaml
jsonparam '/hs/api/v1/cart_cost/{salon_id}/'     get cart_pay    cart_pay.schema.yaml
jsonparam '/hs/api/v1/cart_cost/{salon_id}/'     get client      client.schema.yaml
jsonparam '/hs/api/v2/cart_cost/'                get cart        cart_v2.schema.yaml
jsonparam '/hs/api/v2/cart_cost/'                get payment_list payment_list_v2.schema.yaml

# P2b — component schemas the JSON-query fragment schemas reference
# (CartQueryItem, DeliveryQuery, PaymentItem, CartClientQuery, ServiceIdsQuery,
# RecordItem, TerminalCartQueryItem). Vendor schema names are untouched.
yq -i '.components.schemas = (.components.schemas * load("'"$PATCHES"'/query_schemas.components.yaml"))' "$WORK"

# P3 — usertoken is optional for callers. The vendor marks it
# `required: true` on every client-scoped operation, but AuthMiddleware injects
# it from Credentials; a required parameter would force redundant per-call
# arguments. The declaration is kept (it documents the header) — only the
# required flag is relaxed.
yq -i '(.. | select(type == "!!map" and .name == "usertoken")).required = false' "$WORK"

# P4 — vendor bug: PUT work_schedule 200 response has `content.schema` with no
# media type key. Wrap it under application/json (same shape as its GET twin).
yq -i 'with(.paths."/hs/api/v1/work_schedule/{salon_id}/".put.responses."200".content;
  . = {"application/json": {"schema": .schema}})' "$WORK"

# P5 — error responses are JSON, not text/plain. The vendor tags every
# 400/401/500 body `text/plain` while $ref-ing an object schema; the same
# bodies in the API Blueprint are JSON. Retagged so the generated client
# decodes typed errors. (If a live capture ever shows a real text/plain body,
# revert for the affected ops only.)
yq -i '(.. | select(type == "!!map" and has("text/plain"))) |=
  {"application/json": .["text/plain"]}' "$WORK"

# P6 — global security is OR, not AND. The vendor's `security` requires
# basicAuth and apiKey simultaneously, but its own basicAuth description says
# it is used only for direct-to-database calls, where the apikey is absent.
yq -i '.security = [{"apiKey": []}, {"basicAuth": []}]' "$WORK"


# P7 — schema name collision: the vendor document declares both `cart` (request
# line item) and `Cart` (response array), which both map to Swift `Cart`.
# Renamed doc-side (schema names are not wire data) rather than via
# nameOverrides, which would also rename every `cart` property and parameter.
yq -i '.components.schemas.CartRequestItem = .components.schemas.cart' "$WORK"
yq -i 'del(.components.schemas.cart)' "$WORK"
yq -i '(.. | select(type == "!!map" and .["$ref"] == "#/components/schemas/cart"))."$ref" =
  "#/components/schemas/CartRequestItem"' "$WORK"

# P8 — vendor bug: four operations do not declare the salon_id path parameter
# their path requires (sibling ops on the same paths do). Injected shape:
# required string path param, as declared everywhere else.
sidpathparam() { # $1 path  $2 method
  yq -i '.paths."'"$1"'".'"$2"'.parameters =
    ([{"name": "salon_id", "in": "path", "required": true,
       "schema": {"type": "string"}, "description": "ID салона"}]
     + .paths."'"$1"'".'"$2"'.parameters)' "$WORK"
}
sidpathparam '/hs/api/v1/client/{salon_id}/'        put
sidpathparam '/hs/api/v1/records/{salon_id}/'       put
sidpathparam '/hs/api/v1/sale/{salon_id}/'          put
sidpathparam '/hs/api/v1/work_schedule/{salon_id}/' get
sidpathparam '/hs/api/v1/work_schedule/{salon_id}/' put

# P9 — preserve the .apib's nested-errors dialect on price_list. The vendor
# OpenAPI types `errors` at the envelope top level, but the Blueprint and the
# Apiary mock nest it inside `parameters`; keep an optional `errors` there too
# so either wire shape decodes.
yq -i '.paths."/hs/api/v1/price_list/{salon_id}/".get.responses."200".content."application/json".schema.properties.parameters.properties.errors =
  {"$ref": "#/components/schemas/Errors", "description": "Вложенные ошибки (диалект .apib)"}' "$WORK"

# P10 — vendor bug: `record_array` properties $ref the RecordArray *item*
# schema directly while the wire contract is an array of them ("Массив
# записей"). Wrapped as `type: array` of items. (The component name stays —
# renaming it is cosmetics, not a contract fix.)
yq -i '(.. | select(type == "!!map" and .record_array["$ref"]? == "#/components/schemas/RecordArray")) |=
  (.record_array = {"type": "array",
                    "items": {"$ref": "#/components/schemas/RecordArray"},
                    "description": .record_array.description})' "$WORK"
#   same defect on `payment_list` («Массив структур оплат» — an array of
#   PaymentList items, $ref'd as a bare object) and on `cart` («Массив объектов
#   оплачиваемых номенклатур» — an array of CartRequestItem items).
yq -i '(.. | select(type == "!!map" and .payment_list["$ref"]? == "#/components/schemas/PaymentList")) |=
  (.payment_list = {"type": "array",
                    "items": {"$ref": "#/components/schemas/PaymentList"},
                    "description": .payment_list.description})' "$WORK"
yq -i '(.. | select(type == "!!map" and .cart["$ref"]? == "#/components/schemas/CartRequestItem")) |=
  (.cart = {"type": "array",
            "items": {"$ref": "#/components/schemas/CartRequestItem"},
            "description": .cart.description})' "$WORK"

# P11 — the auth «code sent» variant carries Error/ErrorMessage on the wire
# (Blueprint example), while the vendor schema declares only Parameters+Errors.
# Optional props added so those wire fields stay visible when present.
yq -i '.paths."/hs/api/v1/auth/{salon_id}/".post.responses."200".content."application/json".schema.oneOf[0].properties.Error =
  {"type": "number", "description": "Код ошибки (сингулярный диалект примера)"}' "$WORK"
yq -i '.paths."/hs/api/v1/auth/{salon_id}/".post.responses."200".content."application/json".schema.oneOf[0].properties.ErrorMessage =
  {"type": "string", "description": "Текст ошибки (сингулярный диалект примера)"}' "$WORK"

# P12 — vendor under-typing: `upcoming_dates`/`upcoming_times` on book_staff are
# bare `type: array` with no items, which would generate OpenAPIArrayContainer.
# Their descriptions and examples are ISO-8601 strings.
yq -i '.paths."/hs/api/v1/book_staff/{salon_id}/".get.responses."200".content."application/json".schema.properties.Parameters.items.properties.upcoming_dates.items =
  {"type": "string"}' "$WORK"
yq -i '.paths."/hs/api/v1/book_staff/{salon_id}/".get.responses."200".content."application/json".schema.properties.Parameters.items.properties.upcoming_times.items =
  {"type": "string"}' "$WORK"

# P13 — `type: "null"` inside `oneOf` is valid OpenAPI 3.1 but unsupported by
# the generator (warning: skipped — and the whole property was dropped with it).
# `category_id` is not in `required`, so a bare optional $ref decodes wire `null`
# to nil just the same.
yq -i '.paths."/hs/api/v1/services/{salon_id}/".get.responses."200".content."application/json".schema.properties.Parameters.items.properties.category_id =
  {"description": "Категория услуги (может быть null)", "$ref": "#/components/schemas/IDTitle"}' "$WORK"

# P14 — vendor copy-paste bugs: three properties $ref `#/components/schemas/Errors`
# where an identifier/title belongs. deposit.id is nullable per its own
# description ("если это авансовый счет, то идентификатор null"); the others are
# strings per the vendor's examples.
DL='.paths."/hs/api/v1/deposit_list/{salon_id}/".get.responses."200".content."application/json".schema.properties.Parameters.items.properties.deposit.properties'
yq -i "$DL.id = {\"type\": [\"string\", \"null\"], \"description\": \"Идентификатор счёта (null для авансового)\"}" "$WORK"
yq -i "$DL.title = {\"type\": \"string\", \"description\": \"Наименование счёта\"}" "$WORK"
yq -i '.paths."/hs/api/v1/order_list/{salon_id}/".get.responses."200".content."application/json".schema.properties.parameters.properties.order_list.items.properties.id =
  {"type": "string", "description": "Идентификатор заказа"}' "$WORK"

# P15 — delivery_list[].id is `$ref: ID` but the wire sends null for pickup.
# Type-union keeps it required-with-null, matching the documented example.
yq -i '.paths."/hs/api/v1/delivery_list/{salon_id}".get.responses."200".content."application/json".schema.properties.parameters.items.properties.id =
  {"type": ["string", "null"], "description": "Идентификатор услуги доставки (null для самовывоза)"}' "$WORK"

# P16 — vendor over-required: auth_types items require `method`, but the
# document's own example omits it. Relaxed to [type, title].
yq -i '.paths."/hs/api/v1/auth_types/{salon_id}/".get.responses."200".content."application/json".schema.properties.parameters.items.required = ["type", "title"]' "$WORK"

# P17 — authorize oneOf needs discriminating requireds or the all-optional
# case1 swallows case2 payloads (verified: UserToken response decoded as .case1).
yq -i '.paths."/hs/api/v1/auth/{salon_id}/".post.responses."200".content."application/json".schema.oneOf[0].properties.Parameters.required = ["sent_SMS"]' "$WORK"
yq -i '.paths."/hs/api/v1/auth/{salon_id}/".post.responses."200".content."application/json".schema.oneOf[1].properties.Parameters.required = ["UserToken"]' "$WORK"

# P18 — the services item is `category_id` in the vendor document but `category`
# in the Blueprint's example (the two disagree; TD-6-class field-name drift).
# Declaring both optional keeps either wire spelling decodable.
yq -i '.paths."/hs/api/v1/services/{salon_id}/".get.responses."200".content."application/json".schema.properties.Parameters.items.properties.category =
  {"description": "Категория услуги (поле из примера Blueprint)", "$ref": "#/components/schemas/IDTitle"}' "$WORK"

# P19 — certificates `total`/`balance` are declared `type: string` but the
# vendor's own example sends numbers (5000/2000). The declared string could
# never carry the documented payload; numbers take precedence (TD-6 class).
CERT='.paths."/hs/api/v1/certificates/{salon_id}".get.responses."200".content."application/json".schema.properties.Parameters.items.properties'
yq -i "$CERT.total.type = \"number\"" "$WORK"
yq -i "$CERT.balance.type = \"number\"" "$WORK"

# P20 — vendor omission: PUT client (updateClientById) drops `phone` from the
# request schema while its own example sends `phone: 79211234567` and the
# Blueprint's ClientCreate structure declares it. Typed as on POST (`number`,
# «только цифры») so create and update agree. TD-6 class.
yq -i '.paths."/hs/api/v1/client/{salon_id}/".put.requestBody.content."application/json".schema.properties.phone = {"type": "number", "description": "Номер телефона (только цифры)"}' "$WORK"

# P21 — `salon_id` in request bodies. The Blueprint declares it (required) in
# the bodies of createClient, updateClientById, searchClients and updateRecord;
# the vendor schemas omit it while the vendor examples still send it (an empty
# string on the client ops). Declared optional: the path parameter is
# authoritative and callers who need the duplicate can send it. TD-6 class.
sidbody() { # $1 path  $2 method
  yq -i '.paths."'"$1"'".'"$2"'.requestBody.content."application/json".schema.properties.salon_id =
    {"type": "string",
     "description": "ID салона (дублирует параметр пути; в Blueprint обязателен в теле, в примерах вендора пустая строка)"}' "$WORK"
}
sidbody '/hs/api/v1/client/{salon_id}/'  post
sidbody '/hs/api/v1/client/{salon_id}/'  put
sidbody '/hs/api/v1/clients/{salon_id}/' post
sidbody '/hs/api/v1/records/{salon_id}/' put

# P22 — vendor under-enumeration: searchClients `order_by_direction` enumerates
# only `DESC` (lifted from the example) while its own description reads
# «`ASC` или `DESC`». Both directions declared.
yq -i '.paths."/hs/api/v1/clients/{salon_id}/".post.requestBody.content."application/json".schema.properties.order_by_direction.enum = ["ASC", "DESC"]' "$WORK"

# P23 — vendor under-typing: `Filter.value` is `array` of untyped items while
# its description reads «Может быть как строкой, так и массивом строк». A oneOf
# of string | [string] lets a scalar phone filter be sent.
yq -i '.components.schemas.Filter.properties.value = {"description": "Значение для фильтрации. Может быть как строкой, так и массивом строк", "oneOf": [{"type": "string"}, {"type": "array", "items": {"type": "string"}}]}' "$WORK"

# P24 — vendor omission: the Ticket schema lacks six keys that the vendor's own
# tickets/ticket examples (and the Blueprint's examples) carry: total_frozen,
# balance_frozen, min_frozen_count, total_guest_visit, balance_guest_visit,
# freeze_list. Neither document describes them; declared optional with the
# examples' types (numbers; freeze_list is an array whose item shape is
# undocumented — the examples show only `[]`).
TK='.components.schemas.Ticket.properties'
for k in total_frozen balance_frozen min_frozen_count total_guest_visit balance_guest_visit; do
  yq -i "$TK.$k = {\"type\": \"number\", \"description\": \"Поле из примера вендора; в таблице полей не описано\"}" "$WORK"
done
yq -i '.components.schemas.Ticket.properties.freeze_list = {"type": "array", "items": {}, "description": "Список заморозок (поле из примера вендора; форма элемента не документирована)"}' "$WORK"

# P25 — Blueprint-only response field: the v1 cart_cost field table documents
# `user_token` — «Возвращается, если usertoken не передан в заголовках», i.e.
# the anonymous-cart handle — and the vendor YAML never mentions it. Declared
# optional so an anonymous checkout can read it. TD-6 class until the wire
# confirms either document.
yq -i '.paths."/hs/api/v1/cart_cost/{salon_id}/".get.responses."200".content."application/json".schema.properties.parameters.properties.user_token = {"type": "string", "description": "Токен доступа клиента. Возвращается, если usertoken не передан в заголовках (Blueprint; в YAML вендора отсутствует)"}' "$WORK"

# P26 — rateVisit `comment` is declared `number` in both documents, and both
# documents' examples send the string «Отличное обслуживание». A number cannot
# carry a comment; as with P19 the example takes precedence. TD-6 class.
yq -i '.paths."/hs/api/v1/record_rating/{salon_id}".post.requestBody.content."application/json".schema.properties.comment.type = "string"' "$WORK"

# Header marking the file as generated output.
{ echo '# -----------------------------------------------------------------'
  echo '# GENERATED FILE — do not edit by hand.'
  echo '# Regenerate: Upstream/salon1c-openapi/apply-patches.sh'
  echo '# Source: vendored vendor OpenAPI (api_salon1c.yaml) + declared patches.'
  echo '# -----------------------------------------------------------------'
  cat "$WORK"
} > "$OUT"
echo "wrote $OUT"
