import Foundation
import HTTPTypes
import OpenAPIRuntime
@testable import Salon1cAPI

// MARK: - Transports

/// Returns a canned response without a network. Enough for every decoding test.
struct StubTransport: ClientTransport {
    let status: HTTPResponse.Status
    let json: String

    init(status: HTTPResponse.Status = .ok, json: String) {
        self.status = status
        self.json = json
    }

    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var response = HTTPResponse(status: status)
        response.headerFields[.contentType] = "application/json"
        return (response, HTTPBody(json))
    }
}

/// Captures what the middleware stack produced, then answers like `StubTransport`.
///
/// An `actor`, not a `nonisolated(unsafe) var`: the target is in Swift 6 language mode.
actor RequestRecorder {
    private(set) var request: HTTPRequest?
    private(set) var requestBody: String?

    func record(_ request: HTTPRequest, body: String?) {
        self.request = request
        self.requestBody = body
    }
}

struct RecordingTransport: ClientTransport {
    let recorder: RequestRecorder
    var status: HTTPResponse.Status = .ok
    var json: String = #"{"parameters":{},"errors":{"code":0,"message":""}}"#

    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var text: String?
        if let body {
            text = try await String(collecting: body, upTo: .max)
        }
        await recorder.record(request, body: text)
        var response = HTTPResponse(status: status)
        response.headerFields[.contentType] = "application/json"
        return (response, HTTPBody(json))
    }
}

/// Fails the way a real network failure does, so the error that reaches the caller is a
/// `ClientError` carrying whatever context the runtime chose to attach.
struct FailingTransport: ClientTransport {
    struct Failure: Error {}

    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        throw Failure()
    }
}

// MARK: - Clients under test

extension Client {
    /// A client wired to `StubTransport` through the **production** configuration, so a
    /// decoding test exercises the same converter setup a real call would.
    static func stubbed(status: HTTPResponse.Status = .ok, json: String) throws -> Client {
        Client(
            serverURL: try Servers.Server1.url(),
            transport: StubTransport(status: status, json: json)
        )
    }

    /// A client whose only middleware is `AuthMiddleware`, so the middleware suite sees
    /// exactly what it did and nothing else.
    static func recording(
        recorder: RequestRecorder,
        apiKey: String = "test-apikey",
        userToken: String? = nil,
        json: String = #"{"parameters":{},"errors":{"code":0,"message":""}}"#
    ) throws -> Client {
        Client(
            serverURL: try Servers.Server1.url(),
            transport: RecordingTransport(recorder: recorder, json: json),
            middlewares: [AuthMiddleware(apiKey: apiKey, userToken: userToken)]
        )
    }
}

// MARK: - Response fixtures
//
// Provenance, per fixture, decides what a failure means:
//
// - Every fixture below is **derived from `Upstream/salon1c/salon1c.apib`** — the vendor's
//   API Blueprint — copied verbatim including its inconsistencies, and each names the
//   section it came from. These prove the client decodes what the document *claims*;
//   only a live call proves the claim (TD-2). Replace each one with a wire capture as
//   evidence arrives, and say so here.

enum Fixture {
    /// `GET /hs/api/v1/auth_types/` → 200, verbatim: Group Авторизация → auth_types.
    static let authTypesResponseJSON = #"""
    {
        "parameters": [
            {
                "type": "sms",
                "title": "СМС"
            },
            {
                "type": "whats_app",
                "title": "WhatsApp"
            },
            {
                "type": "email",
                "title": "Email"
            }
        ],
        "errors": {
            "code": 0,
            "message": ""
        }
    }
    """#

    /// `POST /hs/api/v1/auth/` → 200, «код отправлен» variant — the hybrid
    /// `Request_id`/`Parameters`/`Error`/`ErrorMessage` register (TD-5), verbatim.
    static let authCodeSentResponseJSON = #"""
    {
        "Request_id": "580392e6-ba49-4280-ac67-fcd6f2180121",
        "Parameters": {
            "sent_SMS": true
        },
        "Error": 0,
        "ErrorMessage": ""
    }
    """#

    /// `POST /hs/api/v1/auth/` → 200, «UserToken выдан» variant — also the shared
    /// response of `private_auth` and `auth_token`, verbatim.
    static let userTokenEnvelopeResponseJSON = #"""
    {
        "Parameters": {
            "UserToken": "9323751AAB5A5925142F352BBA7913B3"
        },
        "Errors": {
            "code": 0,
            "message": null
        }
    }
    """#

    /// `POST /hs/api/v1/validity_usertoken/` → 200 — the bare, un-enveloped shape (TD-5).
    static let usertokenValidityResponseJSON = #"""
    {
        "Result": true
    }
    """#

    /// `POST /hs/api/v1/auth_request/` → 200, verbatim: Group Авторизация → auth_request.
    static let phoneConfirmationResponseJSON = #"""
    {
        "Parameters": {
            "outgoing_id": "you_can_login_bot",
            "link": "https://t.me/you_can_login_bot/?start=Verification",
            "request_id": "27dd2f8e-32a4-11ee-b18f-f02f7488d897",
            "method": "outgoing_telegram"
        },
        "Errors": {
            "code": 0,
            "message": ""
        }
    }
    """#

    /// `GET /hs/api/v1/book_services/` → 200, verbatim: Group Онлайн запись →
    /// book_services. The doc's example has **no `Errors` key** — kept that way.
    static let bookableServicesResponseJSON = #"""
    {
        "Parameters": [
            {
                "id": "140df5b4-5a58-11e7-82e7-0050568b5c8d",
                "title": "Мезотерапия",
                "category": {
                    "id": "6ceedce5-666a-11e9-899f-2c4d546557dd",
                    "title": "Косметология"
                },
                "price_min": 1100,
                "price_max": 1100,
                "comment": "",
                "active": true,
                "length": 60,
                "ServicesAtSameTime": [
                    "e21cf6d4-5a57-11e7-82e7-0050568b5c8d",
                    "d8329477-5a5a-11e7-82e7-0050568b5c8d"
                ],
                "sort_index": 0
            }
        ]
    }
    """#

    /// `GET /hs/api/v1/book_staff/` → 200: Group Онлайн запись → book_staff.
    /// NOT verbatim — the doc's example is invalid JSON (an orphan
    /// `"comments_count": 1` block between the array and `Errors`) and its second
    /// rating carries the typo `"rsating"`. Repaired to the field table's shape;
    /// the doc's own table is the authority here (TD-6).
    static let bookableStaffResponseJSON = #"""
    {
        "Parameters": [
            {
                "id": "24ed443d-9a02-11e7-8931-2c4d546557dd",
                "name": "Новикова Анна",
                "specialization": {
                    "id": "98340848-0658-11e7-a757-001d7d5c01d0",
                    "title": "Косметолог"
                },
                "weight": 0,
                "information": "",
                "avatar": "http://localhost/Spa3/hs/api/files/123456/24ed443d-9a02-11e7-8931-2c4d546557dd-94953.jpg",
                "upcoming_dates": [
                    "2019-10-29T00:00:00",
                    "2019-10-30T00:00:00",
                    "2019-10-31T00:00:00"
                ],
                "ratings": [
                    {
                        "rating_parameter": {
                            "id": "50a4f2a5-cdc4-11e7-893b-2c4d546557dd",
                            "title": "Оценка"
                        },
                        "rating": 4,
                        "votes_count": 3
                    },
                    {
                        "rating_parameter": {
                            "id": "b1f48dc2-cdc4-11e7-893b-2c4d546557dd",
                            "title": "Скорость"
                        },
                        "rating": 4.5,
                        "votes_count": 2
                    }
                ],
                "comments_count": 3
            }
        ],
        "Errors": {
            "code": 0,
            "message": null
        }
    }
    """#

    /// `GET /hs/api/v1/book_dates/` → 200, verbatim: `Parameters` is a bare array
    /// of ISO-8601 strings.
    static let bookableDatesResponseJSON = #"""
    {
        "Parameters": [
            "2017-08-20T00:00:00",
            "2017-08-21T00:00:00",
            "2017-08-30T00:00:00",
            "2017-08-31T00:00:00"
        ],
        "Errors": {
            "code": 0,
            "message": null
        }
    }
    """#

    /// `GET /hs/api/v1/book_times/` → 200, verbatim (abbreviated to two slots).
    static let bookableTimesResponseJSON = #"""
    {
        "Parameters": [
            {
                "time": "09:00",
                "seance_length": 30,
                "datetime": "2017-08-24T09:00:00"
            },
            {
                "time": "09:30",
                "seance_length": 30,
                "datetime": "2017-08-24T09:30:00"
            }
        ],
        "Errors": {
            "code": 0,
            "message": null
        }
    }
    """#

    /// `GET /hs/api/v1/recording_dates/` → 200, verbatim: dates in the
    /// `дд.мм.гггг чч:мм:сс` dialect (TD-7).
    static let recordingDatesResponseJSON = #"""
    {
        "Parameters": [
            {
                "id": "ef0fd170-3c83-465d-836b-51d72d208831",
                "date": [
                    "06.08.2024 11:00:00",
                    "06.08.2024 11:30:00"
                ]
            }
        ],
        "Errors": {
            "code": 0,
            "message": ""
        }
    }
    """#

    /// `POST /hs/api/v1/book_record/` → 200, verbatim — note `"Errors": null`.
    /// Shared by `change_record` and `cancel_record`.
    static let resultEnvelopeJSON = #"""
    {
        "Parameters": {
            "Result": true
        },
        "Errors": null
    }
    """#

    /// `book_record`'s fuller documented form (the response-shape example the doc
    /// pasted into the request body — its field table is the authority, TD-6).
    static let bookVisitResponseJSON = #"""
    {
        "Parameters": {
            "Result": true,
            "record_id": "d4608b12-5a07-11e9-899e-2c4d546557dd",
            "status": "TemporarilyReservedNeedPayment",
            "sum": 2300,
            "may_be_payment": [
                {
                    "id": "83b95983-4813-11ea-89af-2c4d546557dd",
                    "title": "Основной лицевой счет",
                    "type": "deposit",
                    "payment_amount": 1300
                }
            ]
        },
        "Errors": {
            "code": 0,
            "message": ""
        }
    }
    """#

    /// `GET /hs/api/v1/record_cost/` → 200, verbatim (one cart position) — the
    /// lowercase envelope dialect inside the booking group (TD-5).
    static let recordCostResponseJSON = #"""
    {
        "parameters": {
            "cart": [
                {
                    "purchase": {
                        "id": "9ca0fa6c-48ee-11ea-96bc-38d547b31ac0",
                        "title": "Услуга 90 мин",
                        "type": "service",
                        "validity": null,
                        "description": "Описание услуги",
                        "services": null,
                        "pictures": [
                            "http://localhost/Salon/hs/api/files/0d44270f-e77f-4e45-a9ad-b4612412a48d/fbe55c58-6e42-11ee-b19b-f02f7488d897"
                        ]
                    },
                    "count": 1,
                    "balance": 0,
                    "balance_warning": "",
                    "price_type": {
                        "id": "bb266307-3e83-11ea-96b8-38d547b31ac0",
                        "title": "Розничная цена"
                    },
                    "price": 100,
                    "nds": 1,
                    "nds_sum": 0,
                    "price_with_discount": 50,
                    "discount_sum": 50,
                    "payment_amount": 50
                }
            ],
            "total_amount": 50,
            "total_discount": 50,
            "may_be_payment": [
                {
                    "id": "b9c4c5de-6691-11ef-b1c6-001a7dda7115",
                    "title": "Основной",
                    "type": "deposit",
                    "payment_amount": 50
                }
            ],
            "promotions": [
                {
                    "type": "discount",
                    "title": "50% промокод Test",
                    "amount": 50
                }
            ],
            "promocode": "Test"
        },
        "errors": {
            "code": 0,
            "message": ""
        }
    }
    """#

    /// `GET /hs/api/v1/visites/` → 200, verbatim (one visit, one service):
    /// Group Визиты → visites. `finished_visites` answers the same structure
    /// minus `status`.
    static let visitsResponseJSON = #"""
    {
        "Parameters": [
            {
                "id": "2aa25425-e4f9-11e9-89ab-2c4d546557dd",
                "status": "Finished",
                "actual_start_date": "2019-10-15T14:00:00",
                "actual_end_date": "2019-10-15T14:48:40",
                "services": [
                    {
                        "start_date": "2019-10-02T12:00:00",
                        "end_date": "2019-10-02T12:40:00",
                        "service": {
                            "id": "0c599e34-5b0d-11e7-82e7-0050568b5c8d",
                            "title": "Воздушно-вихревой массаж"
                        },
                        "staff": {
                            "id": "d7d792c2-0571-11e7-a42a-0050568b5c8d",
                            "title": "Ипритова Инга Юрьевна"
                        }
                    }
                ],
                "client": {
                    "id": "eac3bbca-6003-11e7-82e7-0050568b5c8d",
                    "name": "Веселова Алина Ивановна",
                    "phones": [
                        "+7 (999) 8452010"
                    ]
                }
            }
        ],
        "Errors": {
            "code": 0,
            "message": ""
        }
    }
    """#

    /// `GET /hs/api/v1/debt_visits/` → 200, verbatim: PascalCase *inside* the
    /// payload too (TD-5). `Staff` arrives as a string where the field table
    /// declares an object (TD-6); `Department` is example-only.
    static let debtVisitsResponseJSON = #"""
    {
        "Parameters": [
            {
                "Id": "e162eaea-ad88-11e7-8672-2c4d546557dd",
                "CalculationType": null,
                "FiscalCheck": null,
                "Customer": {
                    "Name": "Одношевич Евгений",
                    "Phone": "79876543210",
                    "Email": null
                },
                "Organization": {
                    "TaxationSystemCode": null,
                    "TaxationSystem": "Общая система налогообложения"
                },
                "Services": [
                    {
                        "Name": "Стрижка мужская",
                        "Quantity": 1,
                        "Price": 500,
                        "PriceWithDiscount": 500,
                        "DiscountSum": 0,
                        "Tax": null,
                        "TaxSum": 0,
                        "Staff": "Новикова Анна",
                        "Department": null,
                        "BarCode": null,
                        "CalculationMethod": null,
                        "CalculationObject": null,
                        "Sum": 500
                    }
                ]
            }
        ],
        "Errors": {
            "code": 0,
            "message": null
        }
    }
    """#

    /// `GET /hs/api/v1/client/` → 200, verbatim: Group Клиенты → client
    /// (Информация о клиенте). `sex: null` kept; `email` is an array here.
    static let clientCardResponseJSON = #"""
    {
        "Parameters": {
            "full_name": "Коренина Анна",
            "name": "Анна",
            "second_name": "",
            "last_name": "Коренина",
            "birthday": "31.12.1990",
            "sex": null,
            "email": [
                "Anna172@mail.ru",
                "AnnaKorenina@mail.ru"
            ],
            "records_to_rate": [
                {
                    "record_id": "8f0e6b9e-9a3c-11e9-89ab-2c4d546557dd",
                    "service_title": "Гидромассаж",
                    "staff": {
                        "id": "d7d792c2-0571-11e7-a42a-0050568b5c8d",
                        "name": "Ипритова Инга Юрьевна"
                    },
                    "start_date": "2019-10-02T12:00:00"
                }
            ],
            "cards": [
                {
                    "id": "523d8557-c5b5-11ea-89d3-2c4d546557dd",
                    "title": "Карта №5902047170294",
                    "card_code": "5902047170294",
                    "card_type": "barcode",
                    "link": ""
                }
            ],
            "promocodes": [],
            "status": "constant"
        },
        "Errors": {
            "code": 0,
            "message": null
        }
    }
    """#

    /// `POST /hs/api/v1/clients/` → 200 — CONSTRUCTED per the method's field
    /// table and the `Client`/`Meta` data structures; the doc shows no body
    /// example for this operation (TD-6).
    static let clientsResponseJSON = #"""
    {
        "Parameters": [
            {
                "id": "47efc7f111104513a25b302e6712df59",
                "salon_id": "0d190fc81c0111efb1bff02f7488d897",
                "name": "Иван",
                "surname": "Петров",
                "patronymic": "Васильевич",
                "birth_date": "07.10.1987",
                "phone": "77777777777",
                "email": "client21321@mail.ru",
                "sold_amount": 0,
                "visits_count": 5,
                "sex": "Мужской",
                "sex_id": 1,
                "status": "Постоянный",
                "status_id": 2
            }
        ],
        "Errors": {
            "code": 0,
            "message": ""
        },
        "Meta": {
            "items_count": 10,
            "pages_count": 2,
            "page_current": 1,
            "page_size": 5
        }
    }
    """#

    /// `POST /hs/api/v1/client/` → 201 — CONSTRUCTED per `Parameters (Client)` +
    /// `Errors`; the doc declares 201 without a body example (TD-6).
    static let clientCreatedResponseJSON = #"""
    {
        "Parameters": {
            "id": "47efc7f111104513a25b302e6712df59",
            "salon_id": "0d190fc81c0111efb1bff02f7488d897",
            "name": "Василий",
            "surname": "Соновен",
            "patronymic": "Васильевич",
            "birth_date": "2011-01-01",
            "phone": "79211234567",
            "email": "123456789@gmail.com",
            "sold_amount": 0,
            "visits_count": 0
        },
        "Errors": {
            "code": 0,
            "message": ""
        }
    }
    """#

    /// `POST /hs/api/v1/clients/` and `client` → 400 — CONSTRUCTED per the
    /// `ErrorBadRequest` data structure (`code: 1001` is its own example).
    static let badRequestResponseJSON = #"""
    {
        "Errors": {
            "code": 1001,
            "message": "Неверный формат данных или отсутствует apikey"
        }
    }
    """#

    /// `GET /hs/api/v1/deposit_list/` → 200, verbatim: `history_exist` arrives
    /// as a boolean where the field table declares string (TD-6).
    static let clientAccountsResponseJSON = #"""
    {
        "Parameters": [
            {
                "deposit": {
                    "id": "cced6215-8b97-11e9-89a0-2c4d546557dd",
                    "title": "Основной",
                    "deposit_type": "deposit",
                    "history_exist": true
                },
                "balance": 1700
            },
            {
                "deposit": {
                    "id": "142b0943-8b99-11e9-89a0-2c4d546557dd",
                    "title": "Бонусы",
                    "deposit_type": "bonus",
                    "history_exist": true
                },
                "balance": 1500
            }
        ],
        "Errors": {
            "code": 0,
            "message": ""
        }
    }
    """#

    /// `POST /hs/api/v1/update_client/` → 200, verbatim: `sex` returns as the
    /// localized representation, `email` as an array (TD-6); `Errors: null`.
    static let clientProfileUpdateResponseJSON = #"""
    {
        "Parameters": {
            "Result": true,
            "data_client": {
                "full_name": "Андреева Анна Сергеевна",
                "name": "Анна",
                "second_name": "Сергеевна",
                "last_name": "Андреева",
                "birthday": "31.12.1990",
                "sex": "Женский",
                "email": [
                    "Andreeva1975@mail.ru"
                ]
            }
        },
        "Errors": null
    }
    """#

    /// `GET /hs/api/v1/records_history/` → 200, verbatim (one visit, two
    /// services): name-keyed service/staff structures (TD-5).
    static let clientVisitsResponseJSON = #"""
    {
        "Parameters": [
            {
                "id": "5ee2827f-8a80-11e8-8963-2c4d546557dd",
                "start_date": "2018-07-18T18:00:00",
                "end_date": "2018-07-18T19:00:00",
                "client": {
                    "id": "c27e5408-6003-11e7-82e7-0050568b5c8d",
                    "name": "Баранова Екатерина Сергеевна"
                },
                "status": "arrived",
                "services": [
                    {
                        "start_date": "2018-07-18T19:00:00",
                        "end_date": "2018-07-18T20:00:00",
                        "service": {
                            "id": "e21cf6d4-5a57-11e7-82e7-0050568b5c8d",
                            "name": "Гидромассаж"
                        },
                        "staff": {
                            "id": "d7d792c2-0571-11e7-a42a-0050568b5c8d",
                            "name": "Ипритова Инга Юрьевна"
                        },
                        "count": 2,
                        "sum": 4600
                    }
                ],
                "count_total": 3,
                "sum_total": 6600
            }
        ],
        "Errors": {
            "code": 0,
            "message": ""
        }
    }
    """#

    /// `GET /hs/api/v1/tickets/` → 200, verbatim: the misspelled
    /// `avialable_actions` key kept, frozen/guest fields are example-only.
    static let ticketsResponseJSON = #"""
    {
        "Parameters": [
            {
                "ticket_id": "745f78b9-b1ec-497b-b42e-961a9d9b610a",
                "title": "Пакет 6 услуг",
                "item_id": "d30379c5-b494-11f0-b201-001a7dda7115",
                "type": "package",
                "count": 6,
                "status": "active",
                "active_date": "2025-10-29",
                "end_date": "2025-10-30",
                "start_status_date": "2025-10-29",
                "end_status_date": "2025-10-30",
                "total_frozen": 0,
                "balance_frozen": 0,
                "min_frozen_count": 0,
                "total_guest_visit": 0,
                "balance_guest_visit": 0,
                "type_activation": {
                    "title": "",
                    "type": "at_sale"
                },
                "avialable_actions": [],
                "freeze_list": [],
                "service_list": [
                    {
                        "title": "Услуга 3",
                        "count": 6,
                        "count_reserves": 0
                    }
                ],
                "available_time": null,
                "available_clubs": [
                    {
                        "id": "d9acf4c2-ecb4-11ec-b151-f02f7488d897",
                        "title": "Салон 1"
                    }
                ]
            }
        ],
        "Errors": {
            "code": 0,
            "message": ""
        }
    }
    """#

    /// `GET /hs/api/v1/ticket/` → 200, verbatim: `Parameters` is the single
    /// object, not an array.
    static let ticketResponseJSON = #"""
    {
        "Parameters": {
            "ticket_id": "745f78b9-b1ec-497b-b42e-961a9d9b610a",
            "title": "Пакет 6 услуг",
            "item_id": "d30379c5-b494-11f0-b201-001a7dda7115",
            "type": "package",
            "count": 6,
            "status": "active",
            "active_date": "2025-10-29",
            "end_date": "2025-10-30",
            "start_status_date": "2025-10-29",
            "end_status_date": "2025-10-30",
            "total_frozen": 0,
            "balance_frozen": 0,
            "min_frozen_count": 0,
            "total_guest_visit": 0,
            "balance_guest_visit": 0,
            "type_activation": {
                "title": "",
                "type": "at_sale"
            },
            "avialable_actions": [],
            "freeze_list": [],
            "service_list": [
                {
                    "title": "Услуга 3",
                    "count": 6,
                    "count_reserves": 0
                }
            ],
            "available_time": null,
            "available_clubs": [
                {
                    "id": "d9acf4c2-ecb4-11ec-b151-f02f7488d897",
                    "title": "Салон 1"
                },
                {
                    "id": "04fa8ba4-2ebb-11ed-b15f-f02f7488d897",
                    "title": "Салон 2"
                }
            ]
        },
        "Errors": {
            "code": 0,
            "message": ""
        }
    }
    """#

    /// `GET /hs/api/v1/salons/` → 200 — CONSTRUCTED per the `Salon`/`WorkTime`/
    /// `ContactInformation` data structures; the doc shows no body example (TD-6).
    static let salonsResponseJSON = #"""
    {
        "Parameters": [
            {
                "id": "0d190fc8-1c01-11ef-b1bf-f02f7488d897",
                "title": "OOO \"Салон красоты\"",
                "work_time": [
                    {
                        "active": true,
                        "day": 1,
                        "start": "07:00",
                        "end": "22:00"
                    }
                ],
                "contact_information": {
                    "phone": "78945612233",
                    "email": "test_salon@mail.ru",
                    "address": "г.Москва",
                    "website": "www.website.ru"
                }
            }
        ],
        "Errors": {
            "code": 0,
            "message": ""
        }
    }
    """#

    /// `GET /hs/api/v1/records_list/` → 200 — CONSTRUCTED per the `Records`
    /// data structure's own defaults plus `Meta`; no body example in the doc.
    static let recordsListResponseJSON = #"""
    {
        "Parameters": [
            {
                "id": "7c802c46-a899-4da1-b87c-eb2d68254f0f",
                "salon_id": "0d190fc8-1c01-11ef-b1bf-f02f7488d897",
                "start_date": "2025-06-30T12:00:00",
                "end_date": "2025-06-30T12:15:00",
                "create_date": "2025-06-30T09:49:06",
                "status": "confirmed",
                "comment": "Комментарий",
                "client": {
                    "id": "401b3cea-4d34-4234-b1c0-f5f96551c984",
                    "name": "Савелий",
                    "surname": "Соновен",
                    "patronymic": "Васильевич",
                    "display_name": "Соновен Савелий Васильевич",
                    "phone": "79211234567",
                    "email": "123456789@gmail.com"
                },
                "staffs": [
                    {
                        "id": "d39e5d29-740d-44a1-8c0d-9c873a43805c",
                        "name": "Врач",
                        "specialization": {
                            "id": "a19ee94d-1c00-11ef-b1bf-f02f7488d897",
                            "title": "Врач стоматолог"
                        },
                        "weight": 0,
                        "information": "<img...>",
                        "avatar": null
                    }
                ],
                "services": [
                    {
                        "id": "6ad4c14f-1c03-11ef-b1bf-f02f7488d897",
                        "title": "Услуга 2",
                        "cost": 500,
                        "amount": 1,
                        "cost_per_unit": 500,
                        "first_cost": 500,
                        "discount": 0
                    }
                ],
                "created_user": {
                    "id": "0d191059-1c01-11ef-b1bf-f02f7488d897",
                    "title": "Администратор"
                }
            }
        ],
        "Errors": {
            "code": 0,
            "message": ""
        },
        "Meta": {
            "items_count": 10,
            "pages_count": 2,
            "page_current": 1,
            "page_size": 5
        }
    }
    """#

    /// `GET /hs/api/v1/services/` → 200 — CONSTRUCTED per the method's field
    /// table (`category` object, `staff` array — the data structure disagrees,
    /// TD-6); no body example in the doc.
    static let servicesListResponseJSON = #"""
    {
        "Parameters": [
            {
                "id": "6ad4c14f-1c03-11ef-b1bf-f02f7488d897",
                "title": "Услуга 2",
                "price_min": 500,
                "price_max": 500,
                "weight": 0,
                "category": {
                    "id": "a19ee948-1c00-11ef-b1bf-f02f7488d897",
                    "title": "Хирургия"
                },
                "comment": "",
                "seance_length": 60,
                "active": true,
                "staff": [
                    {
                        "id": "ef0fd170-3c83-465d-836b-51d72d208831",
                        "seance_length": 60
                    }
                ]
            }
        ],
        "Errors": {
            "code": 0,
            "message": ""
        },
        "Meta": {
            "items_count": 10,
            "pages_count": 2,
            "page_current": 1,
            "page_size": 5
        }
    }
    """#

    /// `POST /hs/api/v1/record_rating/` → 200, verbatim: `"Error": null`,
    /// singular — the fifth register variant (TD-5).
    static let rateVisitResponseJSON = #"""
    {
        "Parameters": {
            "Result": true
        },
        "Error": null
    }
    """#

    /// `GET /hs/api/v1/comments/` → 200 — NOT verbatim: the doc's example is
    /// invalid JSON (stray comma and a missing comma around `Pagination`).
    /// Repaired; content unchanged. `Pagination` key — not `Meta` (TD-5).
    static let commentsResponseJSON = #"""
    {
        "Parameters": [
            {
                "staff": {
                    "id": "24ed443d-9a02-11e7-8931-2c4d546557dd",
                    "name": "Новикова Анна"
                },
                "text": "Всё хорошо",
                "date": "2017-11-20T00:00:00",
                "ratings": [
                    {
                        "rating_parameter": {
                            "id": "50a4f2a5-cdc4-11e7-893b-2c4d546557dd",
                            "title": "Оценка"
                        },
                        "rating": 5
                    }
                ],
                "client": {
                    "id": "3d2ef2ef-acce-11e7-8672-2c4d546557dd",
                    "name": "Анна Каренина"
                }
            },
            {
                "text": "Всё отлично",
                "date": "2017-11-20T00:00:00",
                "ratings": [
                    {
                        "rating_parameter": {
                            "id": "50a4f2a5-cdc4-11e7-893b-2c4d546557dd",
                            "title": "Оценка"
                        },
                        "rating": 5
                    }
                ],
                "client": {
                    "id": "90be43e8-bedd-11e7-8939-2c4d546557dd",
                    "name": "Михайлов"
                }
            }
        ],
        "Pagination": {
            "items_count": 22,
            "pages_count": 3,
            "page_current": 1,
            "page_size": 10
        },
        "Errors": {
            "code": 0,
            "message": null
        }
    }
    """#
}

