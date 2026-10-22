// GENERATED FILE — do not edit.
// Regenerate: Scripts/generate-facade.sh
// Source: the generated Types+Operations.swift of the current openapi.yaml.
//
// Operations without a `payload()` — skipped:
//   - authorize: oneOf envelope
//   - getPublicOffer: no JSON body
//   - getPrivacyPolicy: no JSON body

extension Operations.GetAuthTypes.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.GetAuthTypes.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetAuthTypes.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetAuthTypes.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetAuthTypes.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetAuthTypes.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetAuthTypes.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetAuthTypes.id)
        }
    }
}

extension Operations.CheckUserToken.Output {
    /// `result` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Swift.Bool {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            guard let payload = body.result else {
                throw Salon1cError.missingPayload(operation: Operations.CheckUserToken.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.CheckUserToken.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.CheckUserToken.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.CheckUserToken.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.CheckUserToken.id)
        }
    }
}

extension Operations.AuthorizeWithSignature.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.AuthorizeWithSignature.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.AuthorizeWithSignature.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.AuthorizeWithSignature.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.AuthorizeWithSignature.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.AuthorizeWithSignature.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.AuthorizeWithSignature.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.AuthorizeWithSignature.id)
        }
    }
}

extension Operations.RequestPhoneConfirmation.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.RequestPhoneConfirmation.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.RequestPhoneConfirmation.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.RequestPhoneConfirmation.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.RequestPhoneConfirmation.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.RequestPhoneConfirmation.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.RequestPhoneConfirmation.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.RequestPhoneConfirmation.id)
        }
    }
}

extension Operations.GetClientToken.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.GetClientToken.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetClientToken.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetClientToken.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetClientToken.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetClientToken.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetClientToken.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetClientToken.id)
        }
    }
}

extension Operations.GetBookableServices.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.GetBookableServices.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetBookableServices.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetBookableServices.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetBookableServices.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetBookableServices.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetBookableServices.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetBookableServices.id)
        }
    }
}

extension Operations.GetBookableStaff.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.GetBookableStaff.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetBookableStaff.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetBookableStaff.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetBookableStaff.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetBookableStaff.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetBookableStaff.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetBookableStaff.id)
        }
    }
}

extension Operations.GetBookableDates.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> [Swift.String] {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetBookableDates.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetBookableDates.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetBookableDates.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetBookableDates.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetBookableDates.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetBookableDates.id)
        }
    }
}

extension Operations.GetBookableTimes.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.GetBookableTimes.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetBookableTimes.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetBookableTimes.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetBookableTimes.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetBookableTimes.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetBookableTimes.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetBookableTimes.id)
        }
    }
}

extension Operations.GetRecordingDates.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.GetRecordingDates.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetRecordingDates.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetRecordingDates.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetRecordingDates.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetRecordingDates.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetRecordingDates.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetRecordingDates.id)
        }
    }
}

extension Operations.BookVisit.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.BookVisit.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.BookVisit.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.BookVisit.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.BookVisit.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.BookVisit.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.BookVisit.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.BookVisit.id)
        }
    }
}

extension Operations.RescheduleVisit.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.RescheduleVisit.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.RescheduleVisit.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.RescheduleVisit.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.RescheduleVisit.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.RescheduleVisit.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.RescheduleVisit.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.RescheduleVisit.id)
        }
    }
}

extension Operations.CancelVisit.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.CancelVisit.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.CancelVisit.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.CancelVisit.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.CancelVisit.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.CancelVisit.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.CancelVisit.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.CancelVisit.id)
        }
    }
}

extension Operations.GetRecordCost.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.GetRecordCost.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetRecordCost.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetRecordCost.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetRecordCost.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetRecordCost.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetRecordCost.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetRecordCost.id)
        }
    }
}

extension Operations.GetFinishedVisits.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> [Components.Schemas.Visit] {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetFinishedVisits.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetFinishedVisits.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetFinishedVisits.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetFinishedVisits.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetFinishedVisits.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetFinishedVisits.id)
        }
    }
}

extension Operations.GetVisits.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> [Components.Schemas.Visit] {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetVisits.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetVisits.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetVisits.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetVisits.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetVisits.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetVisits.id)
        }
    }
}

extension Operations.GetDebtVisits.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.GetDebtVisits.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetDebtVisits.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetDebtVisits.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetDebtVisits.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetDebtVisits.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetDebtVisits.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetDebtVisits.id)
        }
    }
}

extension Operations.PayVisit.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.PayVisit.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.PayVisit.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.PayVisit.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.PayVisit.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.PayVisit.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.PayVisit.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.PayVisit.id)
        }
    }
}

extension Operations.GetClientInfo.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.GetClientInfo.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetClientInfo.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetClientInfo.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetClientInfo.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetClientInfo.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetClientInfo.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetClientInfo.id)
        }
    }
}

extension Operations.CreateClient.Output {
    /// `parameters` of a 201 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Components.Schemas.Client {
        switch self {
        case .created(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.CreateClient.id)
            return body.parameters
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.CreateClient.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.CreateClient.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.CreateClient.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.CreateClient.id)
        }
    }
}

extension Operations.UpdateClientById.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Components.Schemas.Client {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.UpdateClientById.id)
            return body.parameters
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.UpdateClientById.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.UpdateClientById.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.UpdateClientById.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.UpdateClientById.id)
        }
    }
}

extension Operations.SearchClients.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Paged<[Components.Schemas.Client], Components.Schemas.Meta> {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.SearchClients.id)
            return Paged(items: body.parameters, meta: body.meta)
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.SearchClients.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.SearchClients.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.SearchClients.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.SearchClients.id)
        }
    }
}

extension Operations.GetClientAccounts.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.GetClientAccounts.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetClientAccounts.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetClientAccounts.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetClientAccounts.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetClientAccounts.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetClientAccounts.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetClientAccounts.id)
        }
    }
}

extension Operations.UpdateClientProfile.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.UpdateClientProfile.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.UpdateClientProfile.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.UpdateClientProfile.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.UpdateClientProfile.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.UpdateClientProfile.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.UpdateClientProfile.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.UpdateClientProfile.id)
        }
    }
}

extension Operations.RefillDeposit.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.RefillDeposit.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.RefillDeposit.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.RefillDeposit.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.RefillDeposit.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.RefillDeposit.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.RefillDeposit.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.RefillDeposit.id)
        }
    }
}

extension Operations.GetClientVisitHistory.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> [Components.Schemas.Record] {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetClientVisitHistory.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetClientVisitHistory.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetClientVisitHistory.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetClientVisitHistory.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetClientVisitHistory.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetClientVisitHistory.id)
        }
    }
}

extension Operations.GetClientPlannedVisits.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> [Components.Schemas.Record] {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetClientPlannedVisits.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetClientPlannedVisits.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetClientPlannedVisits.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetClientPlannedVisits.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetClientPlannedVisits.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetClientPlannedVisits.id)
        }
    }
}

extension Operations.UpdateRecord.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> [Components.Schemas.Records] {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.UpdateRecord.id)
            return body.parameters
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.UpdateRecord.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.UpdateRecord.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.UpdateRecord.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.UpdateRecord.id)
        }
    }
}

extension Operations.GetClientTickets.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> [Components.Schemas.Ticket] {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetClientTickets.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetClientTickets.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetClientTickets.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetClientTickets.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetClientTickets.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetClientTickets.id)
        }
    }
}

extension Operations.GetClientTicket.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Components.Schemas.Ticket {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetClientTicket.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetClientTicket.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetClientTicket.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetClientTicket.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetClientTicket.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetClientTicket.id)
        }
    }
}

extension Operations.GetClientCertificates.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.GetClientCertificates.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetClientCertificates.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetClientCertificates.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetClientCertificates.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetClientCertificates.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetClientCertificates.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetClientCertificates.id)
        }
    }
}

extension Operations.GetSalons.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.GetSalons.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetSalons.id)
            return body.parameters
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetSalons.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetSalons.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetSalons.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetSalons.id)
        }
    }
}

extension Operations.GetRecordsList.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Paged<[Components.Schemas.Records], Components.Schemas.Meta> {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetRecordsList.id)
            return Paged(items: body.parameters, meta: body.meta)
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetRecordsList.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetRecordsList.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetRecordsList.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetRecordsList.id)
        }
    }
}

extension Operations.GetServices.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Paged<Operations.GetServices.Output.Ok.Body.JsonPayload.ParametersPayload, Components.Schemas.Meta> {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetServices.id)
            return Paged(items: body.parameters, meta: body.meta)
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetServices.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetServices.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetServices.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetServices.id)
        }
    }
}

extension Operations.RateVisit.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.RateVisit.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.error, operation: Operations.RateVisit.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.RateVisit.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.RateVisit.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.RateVisit.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.RateVisit.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.RateVisit.id)
        }
    }
}

extension Operations.GetComments.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Paged<Operations.GetComments.Output.Ok.Body.JsonPayload.ParametersPayload, Components.Schemas.Meta?> {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetComments.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetComments.id)
            }
            return Paged(items: payload, meta: body.pagination)
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetComments.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetComments.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetComments.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetComments.id)
        }
    }
}

extension Operations.GetPriceList.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.GetPriceList.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetPriceList.id)
            try Salon1cError.check(body.parameters?.errors, operation: Operations.GetPriceList.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetPriceList.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetPriceList.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetPriceList.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetPriceList.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetPriceList.id)
        }
    }
}

extension Operations.GetCartCost.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.GetCartCost.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetCartCost.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetCartCost.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetCartCost.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetCartCost.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetCartCost.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetCartCost.id)
        }
    }
}

extension Operations.PayOrder.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.PayOrder.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.PayOrder.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.PayOrder.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.PayOrder.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.PayOrder.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.PayOrder.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.PayOrder.id)
        }
    }
}

extension Operations.CancelPayment.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.CancelPayment.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.CancelPayment.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.CancelPayment.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.CancelPayment.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.CancelPayment.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.CancelPayment.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.CancelPayment.id)
        }
    }
}

extension Operations.GetProductGroups.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.GetProductGroups.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetProductGroups.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetProductGroups.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetProductGroups.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetProductGroups.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetProductGroups.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetProductGroups.id)
        }
    }
}

extension Operations.GetStoreContacts.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.GetStoreContacts.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetStoreContacts.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetStoreContacts.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetStoreContacts.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetStoreContacts.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetStoreContacts.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetStoreContacts.id)
        }
    }
}

extension Operations.GetOrders.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.GetOrders.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetOrders.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetOrders.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetOrders.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetOrders.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetOrders.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetOrders.id)
        }
    }
}

extension Operations.GetOrderStatuses.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> [Components.Schemas.IDTitle] {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetOrderStatuses.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetOrderStatuses.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetOrderStatuses.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetOrderStatuses.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetOrderStatuses.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetOrderStatuses.id)
        }
    }
}

extension Operations.GetDepositMovements.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.GetDepositMovements.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetDepositMovements.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetDepositMovements.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetDepositMovements.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetDepositMovements.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetDepositMovements.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetDepositMovements.id)
        }
    }
}

extension Operations.GetDeliveryOptions.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.GetDeliveryOptions.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetDeliveryOptions.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetDeliveryOptions.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetDeliveryOptions.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetDeliveryOptions.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetDeliveryOptions.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetDeliveryOptions.id)
        }
    }
}

extension Operations.GetProductFilters.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.GetProductFilters.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetProductFilters.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetProductFilters.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetProductFilters.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetProductFilters.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetProductFilters.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetProductFilters.id)
        }
    }
}

extension Operations.GetTerminalStaff.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.GetTerminalStaff.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetTerminalStaff.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetTerminalStaff.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetTerminalStaff.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetTerminalStaff.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetTerminalStaff.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetTerminalStaff.id)
        }
    }
}

extension Operations.GetTerminalServices.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.GetTerminalServices.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetTerminalServices.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetTerminalServices.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetTerminalServices.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetTerminalServices.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetTerminalServices.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetTerminalServices.id)
        }
    }
}

extension Operations.FindClientByPhone.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.FindClientByPhone.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.FindClientByPhone.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.FindClientByPhone.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.FindClientByPhone.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.FindClientByPhone.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.FindClientByPhone.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.FindClientByPhone.id)
        }
    }
}

extension Operations.AuthorizeTerminal.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.AuthorizeTerminal.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.AuthorizeTerminal.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.AuthorizeTerminal.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.AuthorizeTerminal.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.AuthorizeTerminal.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.AuthorizeTerminal.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.AuthorizeTerminal.id)
        }
    }
}

extension Operations.GetTerminalCartCost.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.GetTerminalCartCost.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetTerminalCartCost.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetTerminalCartCost.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetTerminalCartCost.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetTerminalCartCost.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetTerminalCartCost.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetTerminalCartCost.id)
        }
    }
}

extension Operations.PayTerminal.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.PayTerminal.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.PayTerminal.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.PayTerminal.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.PayTerminal.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.PayTerminal.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.PayTerminal.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.PayTerminal.id)
        }
    }
}

extension Operations.CreateSale.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Components.Schemas.Sale {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.CreateSale.id)
            return body.parameters
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.CreateSale.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.CreateSale.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.CreateSale.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.CreateSale.id)
        }
    }
}

extension Operations.UpdateSale.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Components.Schemas.Sale {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.UpdateSale.id)
            return body.parameters
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.UpdateSale.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.UpdateSale.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.UpdateSale.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.UpdateSale.id)
        }
    }
}

extension Operations.CancelSale.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.CancelSale.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.CancelSale.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.CancelSale.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.CancelSale.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.CancelSale.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.CancelSale.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.CancelSale.id)
        }
    }
}

extension Operations.CreatePaymentLink.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> Operations.CreatePaymentLink.Output.Ok.Body.JsonPayload.ParametersPayload {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.CreatePaymentLink.id)
            return body.parameters
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.CreatePaymentLink.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.CreatePaymentLink.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.CreatePaymentLink.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.CreatePaymentLink.id)
        }
    }
}

extension Operations.GetStaffWorkSchedule.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> [Components.Schemas.WorkSchedule] {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.GetStaffWorkSchedule.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.GetStaffWorkSchedule.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.GetStaffWorkSchedule.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.GetStaffWorkSchedule.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.GetStaffWorkSchedule.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.GetStaffWorkSchedule.id)
        }
    }
}

extension Operations.UpdateStaffWorkSchedule.Output {
    /// `parameters` of a 200 response.
    /// - Throws: ``Salon1cError`` — `.refused` when `errors.code != 0`, `.status` for a documented 400/401/500,
    ///   `.undocumentedStatus` otherwise, `.missingPayload` when a 2xx envelope has neither error nor payload.
    public func payload() throws -> [Components.Schemas.WorkSchedule] {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            try Salon1cError.check(body.errors, operation: Operations.UpdateStaffWorkSchedule.id)
            guard let payload = body.parameters else {
                throw Salon1cError.missingPayload(operation: Operations.UpdateStaffWorkSchedule.id)
            }
            return payload
        case .badRequest(let response):
            throw Salon1cError(status: 400, body: try response.body.json, operation: Operations.UpdateStaffWorkSchedule.id)
        case .unauthorized(let response):
            throw Salon1cError(status: 401, body: try response.body.json, operation: Operations.UpdateStaffWorkSchedule.id)
        case .internalServerError(let response):
            throw Salon1cError(status: 500, body: try response.body.json, operation: Operations.UpdateStaffWorkSchedule.id)
        case .undocumented(let statusCode, _):
            throw Salon1cError.undocumentedStatus(statusCode, operation: Operations.UpdateStaffWorkSchedule.id)
        }
    }
}
