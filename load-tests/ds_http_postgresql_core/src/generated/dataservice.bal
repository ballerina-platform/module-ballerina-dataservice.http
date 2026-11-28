// AUTO-GENERATED FILE. DO NOT MODIFY.

// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.

import ballerina/dataservice;
import ballerina/dataservice.http as dsHttp;
import ballerina/http;
import ballerina/openapi;
import ballerina/persist;

# The listener of the data service.
listener http:Listener dataserviceListener =
        new (dataserviceConfig.port, dataserviceConfig.listenerConfig);

@openapi:ServiceInfo {embed: true, title: "ds_http_postgresql"}
@http:ServiceConfig {cors: dataserviceConfig.serviceConfig.cors}
service http:InterceptableService /api on dataserviceListener {

    private final Client persistClient;
    private final dataservice:PageConfig pageConfig;

    # Creates the persist client, and checks the page sizes.
    #
    # + return - An error when the client cannot be created or a setting is invalid
    function init() returns error? {
        self.persistClient = check new ();
        self.pageConfig = check dataservice:toPageConfig(dataserviceConfig.pageSize, dataserviceConfig.maxPageSize);
    }

    # Answers the errors that `ballerina/http` raises with the `DataserviceError` body.
    #
    # + return - The error interceptor
    public function createInterceptors() returns DataserviceErrorInterceptor => new;

    # Gets a page of customers.
    #
    # + filter - The conditions that the customers match
    # + sort - The fields to sort by, each descending when it starts with `-`
    # + size - The number of customers in the page
    # + offset - The number of customers to skip
    # + fields - The fields to return; the key fields are always returned
    # + return - A page of customers, or the error response
    resource function get customers(CustomerFilter? filter = (),
            string[]? sort = (), int? size = (), int? offset = (), string[]? fields = ())
            returns CustomerList|CustomerPartialList|dsHttp:InvalidInput|dsHttp:InternalError {
        dataservice:Query|dataservice:DataserviceError|dataservice:ConversionError query =
            dataservice:toQuery(dataserviceCustomerEntity, self.pageConfig, filter, sort, size, offset);
        if query !is dataservice:Query {
            return dsHttp:toQueryError(query, "Customer");
        }
        dataservice:DataserviceError? invalidFields =
            dataservice:checkFields(dataserviceCustomerEntity, fields);
        if invalidFields is dataservice:DataserviceError {
            return dsHttp:toQueryError(invalidFields, "Customer");
        }
        stream<Customer, persist:Error?> rows = self.persistClient->/customers(Customer,
            whereClause = query.whereClause, orderByClause = query.orderByClause,
            limitClause = query.limitClause, offsetClause = query.offsetClause
        );
        Customer[]|persist:Error items = from Customer item in rows
            select item;
        if items is persist:Error {
            return dsHttp:toListError(items, "Customer");
        }
        boolean hasMore = dataservice:trimToPage(items, query);
        if fields is string[] {
            Customer[] sources = items;
            map<anydata>[] partials = from Customer item in sources
                select dataservice:selectFields(item, dataserviceCustomerEntity, fields);
            do {
                if dataservice:isIncluded(fields, "orders") {
                    foreach int i in 0 ..< sources.length() {
                        dataservice:Query include = dataservice:toIncludeQuery(
                                dataserviceCustomerEntity, "orders", [sources[i]], self.pageConfig);
                        stream<SalesOrder, persist:Error?> includedRows = self.persistClient->/salesorders(SalesOrder,
                            whereClause = include.whereClause, orderByClause = include.orderByClause,
                            limitClause = include.limitClause
                        );
                        SalesOrderPayload[] included = check from SalesOrder row in includedRows
                            select transformSalesOrderToPayload(row);
                        boolean includedMore = dataservice:trimToPage(included, include);
                        dataservice:attachMany(
                                partials[i], dataserviceCustomerEntity, "orders", included, includedMore, fields);
                    }
                }
            } on fail error err {
                return dsHttp:toListError(err, "Customer");
            }
            CustomerPartial[]|error converted = partials.cloneWithType();
            if converted is error {
                return dsHttp:toListError(converted, "Customer");
            }
            return <CustomerPartialList>{items: converted, hasMore};
        }
        return <CustomerList>{items, hasMore};
    }

    # Gets a customer by its key.
    #
    # + id - The id of the customer
    # + fields - The fields to return; the key fields are always returned
    # + return - The customer, or the error response
    resource function get customers/[int id](string[]? fields = ())
            returns Customer|CustomerPartial|dsHttp:NotFound|dsHttp:InvalidInput|dsHttp:InternalError {
        dataservice:DataserviceError? invalidFields =
            dataservice:checkFields(dataserviceCustomerEntity, fields);
        if invalidFields is dataservice:DataserviceError {
            return dsHttp:toQueryError(invalidFields, "Customer");
        }
        Customer|persist:Error item = self.persistClient->/customers/[id];
        if item is persist:Error {
            return dsHttp:toGetError(item, "Customer", [id]);
        }
        if fields is string[] {
            map<anydata> partial = dataservice:selectFields(item, dataserviceCustomerEntity, fields);
            do {
                if dataservice:isIncluded(fields, "orders") {
                    dataservice:Query include = dataservice:toIncludeQuery(
                            dataserviceCustomerEntity, "orders", [item], self.pageConfig);
                    stream<SalesOrder, persist:Error?> includedRows = self.persistClient->/salesorders(SalesOrder,
                        whereClause = include.whereClause, orderByClause = include.orderByClause,
                        limitClause = include.limitClause
                    );
                    SalesOrderPayload[] included = check from SalesOrder row in includedRows
                        select transformSalesOrderToPayload(row);
                    boolean includedMore = dataservice:trimToPage(included, include);
                    dataservice:attachMany(
                            partial, dataserviceCustomerEntity, "orders", included, includedMore, fields);
                }
            } on fail error err {
                return dsHttp:toGetError(err, "Customer", [id]);
            }
            CustomerPartial|error converted = partial.cloneWithType();
            if converted is error {
                return dsHttp:toGetError(converted, "Customer", [id]);
            }
            return converted;
        }
        return item;
    }

    # Gets the orders of a customer.
    #
    # + id - The id of the customer
    # + filter - The conditions that the orders match
    # + sort - The fields to sort by, each descending when it starts with `-`
    # + size - The number of orders in the page
    # + offset - The number of orders to skip
    # + fields - The fields of the orders to return; the key fields are always returned
    # + return - A page of the orders, or the error response
    resource function get customers/[int id]/orders(SalesOrderFilter? filter = (),
            string[]? sort = (), int? size = (), int? offset = (), string[]? fields = ())
            returns SalesOrderList|SalesOrderRelatedPartialList|dsHttp:NotFound|dsHttp:InvalidInput|dsHttp:InternalError {
        dataservice:DataserviceError? invalidFields =
            dataservice:checkFields(dataserviceSalesOrderEntity, fields, false);
        if invalidFields is dataservice:DataserviceError {
            return dsHttp:toQueryError(invalidFields, "SalesOrder");
        }
        map<anydata> itemKey = {"id": id};
        dataservice:Query|dataservice:DataserviceError|dataservice:ConversionError query =
            dataservice:toRelatedQuery(
                dataserviceCustomerEntity, "orders", itemKey, self.pageConfig, filter, sort, size, offset);
        if query !is dataservice:Query {
            return dsHttp:toQueryError(query, "SalesOrder");
        }
        stream<SalesOrder, persist:Error?> rows = self.persistClient->/salesorders(SalesOrder,
            whereClause = query.whereClause, orderByClause = query.orderByClause,
            limitClause = query.limitClause, offsetClause = query.offsetClause
        );
        SalesOrderPayload[]|persist:Error items = from SalesOrder related in rows
            select transformSalesOrderToPayload(related);
        if items is persist:Error {
            return dsHttp:toListError(items, "Customer", "get related");
        }
        boolean hasMore = dataservice:trimToPage(items, query);
        if items.length() == 0 {
            Customer|persist:Error item = self.persistClient->/customers/[id];
            if item is persist:Error {
                return dsHttp:toGetError(item, "Customer", [id], "get related");
            }
            return <SalesOrderList>{items, hasMore};
        }
        if fields is string[] {
            SalesOrderRelatedPartial[]|error partials = (from SalesOrderPayload related in items
                select dataservice:selectFields(related, dataserviceSalesOrderEntity, fields)).cloneWithType();
            if partials is error {
                return dsHttp:toListError(partials, "Customer", "get related");
            }
            return <SalesOrderRelatedPartialList>{items: partials, hasMore};
        }
        return <SalesOrderList>{items, hasMore};
    }

    # Creates one or more customers.
    #
    # + payload - The customer, or the customers, to create
    # + return - The created customer or customers, or the error response
    resource function post customers(CustomerInsert|CustomerInsert[] payload)
            returns CustomerCreated|CustomerListCreated|dsHttp:InvalidInput|dsHttp:Conflict|dsHttp:ConstraintViolation|dsHttp:InternalError {
        CustomerInsert[] values = payload is CustomerInsert[] ? payload : [payload];
        dataservice:DataserviceError? tooMany = dataservice:checkCreateSize(values.length(), self.pageConfig);
        if tooMany is dataservice:DataserviceError {
            return <dsHttp:InvalidInput>{body: tooMany};
        }
        Customer[] items = [];
        if values.length() > 0 {
            do {
                transaction {
                    int[] keys = check self.persistClient->/customers.post(values);
                    dataservice:KeyValue[][] keyValues = from int key in keys
                        select [key];
                    dataservice:Query query = dataservice:toKeysQuery(dataserviceCustomerEntity, keyValues);
                    stream<Customer, persist:Error?> stored = self.persistClient->/customers(Customer,
                        whereClause = query.whereClause, orderByClause = query.orderByClause
                    );
                    Customer[] rows = check from Customer item in stored
                        select item;
                    check dataservice:orderByKeys(rows, dataserviceCustomerEntity, keyValues);
                    items = rows;
                    check commit;
                }
            } on fail error err {
                return dsHttp:toCreateError(err, "Customer");
            }
        }
        if payload is CustomerInsert[] {
            return <CustomerListCreated>{body: {items, hasMore: false}};
        }
        Customer created = items[0];
        return <CustomerCreated>{
            headers: {"Location": dsHttp:toLocation("/api/customers", [created.id])},
            body: created
        };
    }

    # Updates a customer by its key.
    #
    # + id - The id of the customer
    # + payload - The fields of the customer to update
    # + return - The updated customer, or no content when it cannot be read back, or the error response
    resource function patch customers/[int id](CustomerUpdate payload)
            returns Customer|http:NoContent|dsHttp:NotFound|dsHttp:InvalidInput|dsHttp:Conflict|dsHttp:ConstraintViolation|dsHttp:InternalError {
        Customer|persist:Error item;
        if payload.length() == 0 {
            item = self.persistClient->/customers/[id];
        } else {
            item = self.persistClient->/customers/[id].put(payload);
        }
        if item is persist:Error {
            return dsHttp:toUpdateError(item, "Customer", [id]);
        }
        return item;
    }

    # Deletes a customer by its key.
    #
    # + id - The id of the customer
    # + return - The deleted customer, or the error response
    resource function delete customers/[int id]()
            returns Customer|dsHttp:NotFound|dsHttp:InvalidInput|dsHttp:ConstraintViolation|dsHttp:InternalError {
        Customer|persist:Error item = self.persistClient->/customers/[id].delete();
        if item is persist:Error {
            return dsHttp:toDeleteError(item, "Customer", [id]);
        }
        return item;
    }

    # Gets a page of sales orders.
    #
    # + filter - The conditions that the sales orders match
    # + sort - The fields to sort by, each descending when it starts with `-`
    # + size - The number of sales orders in the page
    # + offset - The number of sales orders to skip
    # + fields - The fields to return; the key fields are always returned
    # + return - A page of sales orders, or the error response
    resource function get salesOrders(SalesOrderFilter? filter = (),
            string[]? sort = (), int? size = (), int? offset = (), string[]? fields = ())
            returns SalesOrderList|SalesOrderPartialList|dsHttp:InvalidInput|dsHttp:InternalError {
        dataservice:Query|dataservice:DataserviceError|dataservice:ConversionError query =
            dataservice:toQuery(dataserviceSalesOrderEntity, self.pageConfig, filter, sort, size, offset);
        if query !is dataservice:Query {
            return dsHttp:toQueryError(query, "SalesOrder");
        }
        dataservice:DataserviceError? invalidFields =
            dataservice:checkFields(dataserviceSalesOrderEntity, fields);
        if invalidFields is dataservice:DataserviceError {
            return dsHttp:toQueryError(invalidFields, "SalesOrder");
        }
        stream<SalesOrder, persist:Error?> rows = self.persistClient->/salesorders(SalesOrder,
            whereClause = query.whereClause, orderByClause = query.orderByClause,
            limitClause = query.limitClause, offsetClause = query.offsetClause
        );
        SalesOrderPayload[]|persist:Error items = from SalesOrder item in rows
            select transformSalesOrderToPayload(item);
        if items is persist:Error {
            return dsHttp:toListError(items, "SalesOrder");
        }
        boolean hasMore = dataservice:trimToPage(items, query);
        if fields is string[] {
            SalesOrderPayload[] sources = items;
            map<anydata>[] partials = from SalesOrderPayload item in sources
                select dataservice:selectFields(item, dataserviceSalesOrderEntity, fields);
            do {
                if dataservice:isIncluded(fields, "customer") {
                    dataservice:Query include = dataservice:toIncludeQuery(
                            dataserviceSalesOrderEntity, "customer", sources, self.pageConfig);
                    stream<Customer, persist:Error?> includedRows = self.persistClient->/customers(Customer,
                        whereClause = include.whereClause, orderByClause = include.orderByClause
                    );
                    Customer[] included = check from Customer row in includedRows
                        select row;
                    dataservice:attachOne(
                            partials, sources, dataserviceSalesOrderEntity, "customer", included, fields);
                }
                if dataservice:isIncluded(fields, "items") {
                    foreach int i in 0 ..< sources.length() {
                        dataservice:Query include = dataservice:toIncludeQuery(
                                dataserviceSalesOrderEntity, "items", [sources[i]], self.pageConfig);
                        stream<OrderItem, persist:Error?> includedRows = self.persistClient->/orderitems(OrderItem,
                            whereClause = include.whereClause, orderByClause = include.orderByClause,
                            limitClause = include.limitClause
                        );
                        OrderItem[] included = check from OrderItem row in includedRows
                            select row;
                        boolean includedMore = dataservice:trimToPage(included, include);
                        dataservice:attachMany(
                                partials[i], dataserviceSalesOrderEntity, "items", included, includedMore, fields);
                    }
                }
            } on fail error err {
                return dsHttp:toListError(err, "SalesOrder");
            }
            SalesOrderPartial[]|error converted = partials.cloneWithType();
            if converted is error {
                return dsHttp:toListError(converted, "SalesOrder");
            }
            return <SalesOrderPartialList>{items: converted, hasMore};
        }
        return <SalesOrderList>{items, hasMore};
    }

    # Gets a sales order by its key.
    #
    # + id - The id of the sales order
    # + fields - The fields to return; the key fields are always returned
    # + return - The sales order, or the error response
    resource function get salesOrders/[int id](string[]? fields = ())
            returns SalesOrderPayload|SalesOrderPartial|dsHttp:NotFound|dsHttp:InvalidInput|dsHttp:InternalError {
        dataservice:DataserviceError? invalidFields =
            dataservice:checkFields(dataserviceSalesOrderEntity, fields);
        if invalidFields is dataservice:DataserviceError {
            return dsHttp:toQueryError(invalidFields, "SalesOrder");
        }
        SalesOrder|persist:Error item = self.persistClient->/salesorders/[id];
        if item is persist:Error {
            return dsHttp:toGetError(item, "SalesOrder", [id]);
        }
        if fields is string[] {
            SalesOrderPayload itemPayload = transformSalesOrderToPayload(item);
            map<anydata> partial = dataservice:selectFields(itemPayload, dataserviceSalesOrderEntity, fields);
            do {
                if dataservice:isIncluded(fields, "customer") {
                    dataservice:Query include = dataservice:toIncludeQuery(
                            dataserviceSalesOrderEntity, "customer", [itemPayload], self.pageConfig);
                    stream<Customer, persist:Error?> includedRows = self.persistClient->/customers(Customer,
                        whereClause = include.whereClause, orderByClause = include.orderByClause
                    );
                    Customer[] included = check from Customer row in includedRows
                        select row;
                    dataservice:attachOne(
                            [partial], [itemPayload], dataserviceSalesOrderEntity, "customer", included, fields);
                }
                if dataservice:isIncluded(fields, "items") {
                    dataservice:Query include = dataservice:toIncludeQuery(
                            dataserviceSalesOrderEntity, "items", [itemPayload], self.pageConfig);
                    stream<OrderItem, persist:Error?> includedRows = self.persistClient->/orderitems(OrderItem,
                        whereClause = include.whereClause, orderByClause = include.orderByClause,
                        limitClause = include.limitClause
                    );
                    OrderItem[] included = check from OrderItem row in includedRows
                        select row;
                    boolean includedMore = dataservice:trimToPage(included, include);
                    dataservice:attachMany(
                            partial, dataserviceSalesOrderEntity, "items", included, includedMore, fields);
                }
            } on fail error err {
                return dsHttp:toGetError(err, "SalesOrder", [id]);
            }
            SalesOrderPartial|error converted = partial.cloneWithType();
            if converted is error {
                return dsHttp:toGetError(converted, "SalesOrder", [id]);
            }
            return converted;
        }
        return transformSalesOrderToPayload(item);
    }

    # Gets the customer of a sales order.
    #
    # + id - The id of the sales order
    # + fields - The fields of the customer to return; the key fields are always returned
    # + return - The customer, or the error response
    resource function get salesOrders/[int id]/customer(string[]? fields = ())
            returns Customer|CustomerRelatedPartial|dsHttp:NotFound|dsHttp:InvalidInput|dsHttp:InternalError {
        dataservice:DataserviceError? invalidFields =
            dataservice:checkFields(dataserviceCustomerEntity, fields, false);
        if invalidFields is dataservice:DataserviceError {
            return dsHttp:toQueryError(invalidFields, "Customer");
        }
        SalesOrder|persist:Error item = self.persistClient->/salesorders/[id];
        if item is persist:Error {
            return dsHttp:toGetError(item, "SalesOrder", [id], "get related");
        }
        Customer|persist:Error related = self.persistClient->/customers/[item.customerId];
        if related is persist:NotFoundError {
            return <dsHttp:NotFound>{body: dataservice:toRelatedNotFoundError(dataserviceSalesOrderEntity, "customer", [id])};
        }
        if related is persist:Error {
            return dsHttp:toListError(related, "SalesOrder", "get related");
        }
        if fields is string[] {
            CustomerRelatedPartial|error partial =
                dataservice:selectFields(related, dataserviceCustomerEntity, fields).cloneWithType();
            if partial is error {
                return dsHttp:toListError(partial, "SalesOrder", "get related");
            }
            return partial;
        }
        return related;
    }

    # Gets the items of a sales order.
    #
    # + id - The id of the sales order
    # + filter - The conditions that the items match
    # + sort - The fields to sort by, each descending when it starts with `-`
    # + size - The number of items in the page
    # + offset - The number of items to skip
    # + fields - The fields of the items to return; the key fields are always returned
    # + return - A page of the items, or the error response
    resource function get salesOrders/[int id]/items(OrderItemFilter? filter = (),
            string[]? sort = (), int? size = (), int? offset = (), string[]? fields = ())
            returns OrderItemList|OrderItemRelatedPartialList|dsHttp:NotFound|dsHttp:InvalidInput|dsHttp:InternalError {
        dataservice:DataserviceError? invalidFields =
            dataservice:checkFields(dataserviceOrderItemEntity, fields, false);
        if invalidFields is dataservice:DataserviceError {
            return dsHttp:toQueryError(invalidFields, "OrderItem");
        }
        map<anydata> itemKey = {"id": id};
        dataservice:Query|dataservice:DataserviceError|dataservice:ConversionError query =
            dataservice:toRelatedQuery(
                dataserviceSalesOrderEntity, "items", itemKey, self.pageConfig, filter, sort, size, offset);
        if query !is dataservice:Query {
            return dsHttp:toQueryError(query, "OrderItem");
        }
        stream<OrderItem, persist:Error?> rows = self.persistClient->/orderitems(OrderItem,
            whereClause = query.whereClause, orderByClause = query.orderByClause,
            limitClause = query.limitClause, offsetClause = query.offsetClause
        );
        OrderItem[]|persist:Error items = from OrderItem related in rows
            select related;
        if items is persist:Error {
            return dsHttp:toListError(items, "SalesOrder", "get related");
        }
        boolean hasMore = dataservice:trimToPage(items, query);
        if items.length() == 0 {
            SalesOrder|persist:Error item = self.persistClient->/salesorders/[id];
            if item is persist:Error {
                return dsHttp:toGetError(item, "SalesOrder", [id], "get related");
            }
            return <OrderItemList>{items, hasMore};
        }
        if fields is string[] {
            OrderItemRelatedPartial[]|error partials = (from OrderItem related in items
                select dataservice:selectFields(related, dataserviceOrderItemEntity, fields)).cloneWithType();
            if partials is error {
                return dsHttp:toListError(partials, "SalesOrder", "get related");
            }
            return <OrderItemRelatedPartialList>{items: partials, hasMore};
        }
        return <OrderItemList>{items, hasMore};
    }

    # Creates one or more sales orders.
    #
    # + payload - The sales order, or the sales orders, to create
    # + return - The created sales order or sales orders, or the error response
    resource function post salesOrders(SalesOrderInsertPayload|SalesOrderInsertPayload[] payload)
            returns SalesOrderCreated|SalesOrderListCreated|dsHttp:InvalidInput|dsHttp:Conflict|dsHttp:ConstraintViolation|dsHttp:InternalError {
        SalesOrderInsertPayload[] entries = payload is SalesOrderInsertPayload[] ? payload : [payload];
        dataservice:DataserviceError? tooMany = dataservice:checkCreateSize(entries.length(), self.pageConfig);
        if tooMany is dataservice:DataserviceError {
            return <dsHttp:InvalidInput>{body: tooMany};
        }
        SalesOrderInsert[] values = [];
        foreach SalesOrderInsertPayload entry in entries {
            SalesOrderInsert|dsHttp:InvalidInput value = transformPayloadToSalesOrderInsert(entry);
            if value is dsHttp:InvalidInput {
                return value;
            }
            values.push(value);
        }
        SalesOrderPayload[] items = [];
        if values.length() > 0 {
            do {
                transaction {
                    int[] keys = check self.persistClient->/salesorders.post(values);
                    dataservice:KeyValue[][] keyValues = from int key in keys
                        select [key];
                    dataservice:Query query = dataservice:toKeysQuery(dataserviceSalesOrderEntity, keyValues);
                    stream<SalesOrder, persist:Error?> stored = self.persistClient->/salesorders(SalesOrder,
                        whereClause = query.whereClause, orderByClause = query.orderByClause
                    );
                    SalesOrder[] rows = check from SalesOrder item in stored
                        select item;
                    check dataservice:orderByKeys(rows, dataserviceSalesOrderEntity, keyValues);
                    items = from SalesOrder item in rows
                        select transformSalesOrderToPayload(item);
                    check commit;
                }
            } on fail error err {
                return dsHttp:toCreateError(err, "SalesOrder");
            }
        }
        if payload is SalesOrderInsertPayload[] {
            return <SalesOrderListCreated>{body: {items, hasMore: false}};
        }
        SalesOrderPayload created = items[0];
        return <SalesOrderCreated>{
            headers: {"Location": dsHttp:toLocation("/api/salesOrders", [created.id])},
            body: created
        };
    }

    # Updates a sales order by its key.
    #
    # + id - The id of the sales order
    # + payload - The fields of the sales order to update
    # + return - The updated sales order, or no content when it cannot be read back, or the error response
    resource function patch salesOrders/[int id](SalesOrderUpdatePayload payload)
            returns SalesOrderPayload|http:NoContent|dsHttp:NotFound|dsHttp:InvalidInput|dsHttp:Conflict|dsHttp:ConstraintViolation|dsHttp:InternalError {
        SalesOrderUpdate|dsHttp:InvalidInput value = transformPayloadToSalesOrderUpdate(payload);
        if value is dsHttp:InvalidInput {
            return value;
        }
        SalesOrder|persist:Error item;
        if value.length() == 0 {
            item = self.persistClient->/salesorders/[id];
        } else {
            item = self.persistClient->/salesorders/[id].put(value);
        }
        if item is persist:Error {
            return dsHttp:toUpdateError(item, "SalesOrder", [id]);
        }
        return transformSalesOrderToPayload(item);
    }

    # Deletes a sales order by its key.
    #
    # + id - The id of the sales order
    # + return - The deleted sales order, or the error response
    resource function delete salesOrders/[int id]()
            returns SalesOrderPayload|dsHttp:NotFound|dsHttp:InvalidInput|dsHttp:ConstraintViolation|dsHttp:InternalError {
        SalesOrder|persist:Error item = self.persistClient->/salesorders/[id].delete();
        if item is persist:Error {
            return dsHttp:toDeleteError(item, "SalesOrder", [id]);
        }
        return transformSalesOrderToPayload(item);
    }

    # Gets a page of order items.
    #
    # + filter - The conditions that the order items match
    # + sort - The fields to sort by, each descending when it starts with `-`
    # + size - The number of order items in the page
    # + offset - The number of order items to skip
    # + fields - The fields to return; the key fields are always returned
    # + return - A page of order items, or the error response
    resource function get orderItems(OrderItemFilter? filter = (),
            string[]? sort = (), int? size = (), int? offset = (), string[]? fields = ())
            returns OrderItemList|OrderItemPartialList|dsHttp:InvalidInput|dsHttp:InternalError {
        dataservice:Query|dataservice:DataserviceError|dataservice:ConversionError query =
            dataservice:toQuery(dataserviceOrderItemEntity, self.pageConfig, filter, sort, size, offset);
        if query !is dataservice:Query {
            return dsHttp:toQueryError(query, "OrderItem");
        }
        dataservice:DataserviceError? invalidFields =
            dataservice:checkFields(dataserviceOrderItemEntity, fields);
        if invalidFields is dataservice:DataserviceError {
            return dsHttp:toQueryError(invalidFields, "OrderItem");
        }
        stream<OrderItem, persist:Error?> rows = self.persistClient->/orderitems(OrderItem,
            whereClause = query.whereClause, orderByClause = query.orderByClause,
            limitClause = query.limitClause, offsetClause = query.offsetClause
        );
        OrderItem[]|persist:Error items = from OrderItem item in rows
            select item;
        if items is persist:Error {
            return dsHttp:toListError(items, "OrderItem");
        }
        boolean hasMore = dataservice:trimToPage(items, query);
        if fields is string[] {
            OrderItem[] sources = items;
            map<anydata>[] partials = from OrderItem item in sources
                select dataservice:selectFields(item, dataserviceOrderItemEntity, fields);
            do {
                if dataservice:isIncluded(fields, "salesOrder") {
                    dataservice:Query include = dataservice:toIncludeQuery(
                            dataserviceOrderItemEntity, "salesOrder", sources, self.pageConfig);
                    stream<SalesOrder, persist:Error?> includedRows = self.persistClient->/salesorders(SalesOrder,
                        whereClause = include.whereClause, orderByClause = include.orderByClause
                    );
                    SalesOrderPayload[] included = check from SalesOrder row in includedRows
                        select transformSalesOrderToPayload(row);
                    dataservice:attachOne(
                            partials, sources, dataserviceOrderItemEntity, "salesOrder", included, fields);
                }
                if dataservice:isIncluded(fields, "product") {
                    dataservice:Query include = dataservice:toIncludeQuery(
                            dataserviceOrderItemEntity, "product", sources, self.pageConfig);
                    stream<Product, persist:Error?> includedRows = self.persistClient->/products(Product,
                        whereClause = include.whereClause, orderByClause = include.orderByClause
                    );
                    Product[] included = check from Product row in includedRows
                        select row;
                    dataservice:attachOne(
                            partials, sources, dataserviceOrderItemEntity, "product", included, fields);
                }
            } on fail error err {
                return dsHttp:toListError(err, "OrderItem");
            }
            OrderItemPartial[]|error converted = partials.cloneWithType();
            if converted is error {
                return dsHttp:toListError(converted, "OrderItem");
            }
            return <OrderItemPartialList>{items: converted, hasMore};
        }
        return <OrderItemList>{items, hasMore};
    }

    # Gets an order item by its key.
    #
    # + id - The id of the order item
    # + fields - The fields to return; the key fields are always returned
    # + return - The order item, or the error response
    resource function get orderItems/[int id](string[]? fields = ())
            returns OrderItem|OrderItemPartial|dsHttp:NotFound|dsHttp:InvalidInput|dsHttp:InternalError {
        dataservice:DataserviceError? invalidFields =
            dataservice:checkFields(dataserviceOrderItemEntity, fields);
        if invalidFields is dataservice:DataserviceError {
            return dsHttp:toQueryError(invalidFields, "OrderItem");
        }
        OrderItem|persist:Error item = self.persistClient->/orderitems/[id];
        if item is persist:Error {
            return dsHttp:toGetError(item, "OrderItem", [id]);
        }
        if fields is string[] {
            map<anydata> partial = dataservice:selectFields(item, dataserviceOrderItemEntity, fields);
            do {
                if dataservice:isIncluded(fields, "salesOrder") {
                    dataservice:Query include = dataservice:toIncludeQuery(
                            dataserviceOrderItemEntity, "salesOrder", [item], self.pageConfig);
                    stream<SalesOrder, persist:Error?> includedRows = self.persistClient->/salesorders(SalesOrder,
                        whereClause = include.whereClause, orderByClause = include.orderByClause
                    );
                    SalesOrderPayload[] included = check from SalesOrder row in includedRows
                        select transformSalesOrderToPayload(row);
                    dataservice:attachOne(
                            [partial], [item], dataserviceOrderItemEntity, "salesOrder", included, fields);
                }
                if dataservice:isIncluded(fields, "product") {
                    dataservice:Query include = dataservice:toIncludeQuery(
                            dataserviceOrderItemEntity, "product", [item], self.pageConfig);
                    stream<Product, persist:Error?> includedRows = self.persistClient->/products(Product,
                        whereClause = include.whereClause, orderByClause = include.orderByClause
                    );
                    Product[] included = check from Product row in includedRows
                        select row;
                    dataservice:attachOne(
                            [partial], [item], dataserviceOrderItemEntity, "product", included, fields);
                }
            } on fail error err {
                return dsHttp:toGetError(err, "OrderItem", [id]);
            }
            OrderItemPartial|error converted = partial.cloneWithType();
            if converted is error {
                return dsHttp:toGetError(converted, "OrderItem", [id]);
            }
            return converted;
        }
        return item;
    }

    # Gets the sales order of an order item.
    #
    # + id - The id of the order item
    # + fields - The fields of the sales order to return; the key fields are always returned
    # + return - The sales order, or the error response
    resource function get orderItems/[int id]/salesOrder(string[]? fields = ())
            returns SalesOrderPayload|SalesOrderRelatedPartial|dsHttp:NotFound|dsHttp:InvalidInput|dsHttp:InternalError {
        dataservice:DataserviceError? invalidFields =
            dataservice:checkFields(dataserviceSalesOrderEntity, fields, false);
        if invalidFields is dataservice:DataserviceError {
            return dsHttp:toQueryError(invalidFields, "SalesOrder");
        }
        OrderItem|persist:Error item = self.persistClient->/orderitems/[id];
        if item is persist:Error {
            return dsHttp:toGetError(item, "OrderItem", [id], "get related");
        }
        SalesOrder|persist:Error related = self.persistClient->/salesorders/[item.salesorderId];
        if related is persist:NotFoundError {
            return <dsHttp:NotFound>{body: dataservice:toRelatedNotFoundError(dataserviceOrderItemEntity, "salesOrder", [id])};
        }
        if related is persist:Error {
            return dsHttp:toListError(related, "OrderItem", "get related");
        }
        if fields is string[] {
            SalesOrderRelatedPartial|error partial =
                dataservice:selectFields(transformSalesOrderToPayload(related), dataserviceSalesOrderEntity, fields).cloneWithType();
            if partial is error {
                return dsHttp:toListError(partial, "OrderItem", "get related");
            }
            return partial;
        }
        return transformSalesOrderToPayload(related);
    }

    # Gets the product of an order item.
    #
    # + id - The id of the order item
    # + fields - The fields of the product to return; the key fields are always returned
    # + return - The product, or the error response
    resource function get orderItems/[int id]/product(string[]? fields = ())
            returns Product|ProductRelatedPartial|dsHttp:NotFound|dsHttp:InvalidInput|dsHttp:InternalError {
        dataservice:DataserviceError? invalidFields =
            dataservice:checkFields(dataserviceProductEntity, fields, false);
        if invalidFields is dataservice:DataserviceError {
            return dsHttp:toQueryError(invalidFields, "Product");
        }
        OrderItem|persist:Error item = self.persistClient->/orderitems/[id];
        if item is persist:Error {
            return dsHttp:toGetError(item, "OrderItem", [id], "get related");
        }
        Product|persist:Error related = self.persistClient->/products/[item.productId];
        if related is persist:NotFoundError {
            return <dsHttp:NotFound>{body: dataservice:toRelatedNotFoundError(dataserviceOrderItemEntity, "product", [id])};
        }
        if related is persist:Error {
            return dsHttp:toListError(related, "OrderItem", "get related");
        }
        if fields is string[] {
            ProductRelatedPartial|error partial =
                dataservice:selectFields(related, dataserviceProductEntity, fields).cloneWithType();
            if partial is error {
                return dsHttp:toListError(partial, "OrderItem", "get related");
            }
            return partial;
        }
        return related;
    }

    # Creates one or more order items.
    #
    # + payload - The order item, or the order items, to create
    # + return - The created order item or order items, or the error response
    resource function post orderItems(OrderItemInsert|OrderItemInsert[] payload)
            returns OrderItemCreated|OrderItemListCreated|dsHttp:InvalidInput|dsHttp:Conflict|dsHttp:ConstraintViolation|dsHttp:InternalError {
        OrderItemInsert[] values = payload is OrderItemInsert[] ? payload : [payload];
        dataservice:DataserviceError? tooMany = dataservice:checkCreateSize(values.length(), self.pageConfig);
        if tooMany is dataservice:DataserviceError {
            return <dsHttp:InvalidInput>{body: tooMany};
        }
        OrderItem[] items = [];
        if values.length() > 0 {
            do {
                transaction {
                    int[] keys = check self.persistClient->/orderitems.post(values);
                    dataservice:KeyValue[][] keyValues = from int key in keys
                        select [key];
                    dataservice:Query query = dataservice:toKeysQuery(dataserviceOrderItemEntity, keyValues);
                    stream<OrderItem, persist:Error?> stored = self.persistClient->/orderitems(OrderItem,
                        whereClause = query.whereClause, orderByClause = query.orderByClause
                    );
                    OrderItem[] rows = check from OrderItem item in stored
                        select item;
                    check dataservice:orderByKeys(rows, dataserviceOrderItemEntity, keyValues);
                    items = rows;
                    check commit;
                }
            } on fail error err {
                return dsHttp:toCreateError(err, "OrderItem");
            }
        }
        if payload is OrderItemInsert[] {
            return <OrderItemListCreated>{body: {items, hasMore: false}};
        }
        OrderItem created = items[0];
        return <OrderItemCreated>{
            headers: {"Location": dsHttp:toLocation("/api/orderItems", [created.id])},
            body: created
        };
    }

    # Updates an order item by its key.
    #
    # + id - The id of the order item
    # + payload - The fields of the order item to update
    # + return - The updated order item, or no content when it cannot be read back, or the error response
    resource function patch orderItems/[int id](OrderItemUpdate payload)
            returns OrderItem|http:NoContent|dsHttp:NotFound|dsHttp:InvalidInput|dsHttp:Conflict|dsHttp:ConstraintViolation|dsHttp:InternalError {
        OrderItem|persist:Error item;
        if payload.length() == 0 {
            item = self.persistClient->/orderitems/[id];
        } else {
            item = self.persistClient->/orderitems/[id].put(payload);
        }
        if item is persist:Error {
            return dsHttp:toUpdateError(item, "OrderItem", [id]);
        }
        return item;
    }

    # Deletes an order item by its key.
    #
    # + id - The id of the order item
    # + return - The deleted order item, or the error response
    resource function delete orderItems/[int id]()
            returns OrderItem|dsHttp:NotFound|dsHttp:InvalidInput|dsHttp:ConstraintViolation|dsHttp:InternalError {
        OrderItem|persist:Error item = self.persistClient->/orderitems/[id].delete();
        if item is persist:Error {
            return dsHttp:toDeleteError(item, "OrderItem", [id]);
        }
        return item;
    }

    # Gets a page of products.
    #
    # + filter - The conditions that the products match
    # + sort - The fields to sort by, each descending when it starts with `-`
    # + size - The number of products in the page
    # + offset - The number of products to skip
    # + fields - The fields to return; the key fields are always returned
    # + return - A page of products, or the error response
    resource function get products(ProductFilter? filter = (),
            string[]? sort = (), int? size = (), int? offset = (), string[]? fields = ())
            returns ProductList|ProductPartialList|dsHttp:InvalidInput|dsHttp:InternalError {
        dataservice:Query|dataservice:DataserviceError|dataservice:ConversionError query =
            dataservice:toQuery(dataserviceProductEntity, self.pageConfig, filter, sort, size, offset);
        if query !is dataservice:Query {
            return dsHttp:toQueryError(query, "Product");
        }
        dataservice:DataserviceError? invalidFields =
            dataservice:checkFields(dataserviceProductEntity, fields);
        if invalidFields is dataservice:DataserviceError {
            return dsHttp:toQueryError(invalidFields, "Product");
        }
        stream<Product, persist:Error?> rows = self.persistClient->/products(Product,
            whereClause = query.whereClause, orderByClause = query.orderByClause,
            limitClause = query.limitClause, offsetClause = query.offsetClause
        );
        Product[]|persist:Error items = from Product item in rows
            select item;
        if items is persist:Error {
            return dsHttp:toListError(items, "Product");
        }
        boolean hasMore = dataservice:trimToPage(items, query);
        if fields is string[] {
            Product[] sources = items;
            map<anydata>[] partials = from Product item in sources
                select dataservice:selectFields(item, dataserviceProductEntity, fields);
            do {
                if dataservice:isIncluded(fields, "orderItems") {
                    foreach int i in 0 ..< sources.length() {
                        dataservice:Query include = dataservice:toIncludeQuery(
                                dataserviceProductEntity, "orderItems", [sources[i]], self.pageConfig);
                        stream<OrderItem, persist:Error?> includedRows = self.persistClient->/orderitems(OrderItem,
                            whereClause = include.whereClause, orderByClause = include.orderByClause,
                            limitClause = include.limitClause
                        );
                        OrderItem[] included = check from OrderItem row in includedRows
                            select row;
                        boolean includedMore = dataservice:trimToPage(included, include);
                        dataservice:attachMany(
                                partials[i], dataserviceProductEntity, "orderItems", included, includedMore, fields);
                    }
                }
            } on fail error err {
                return dsHttp:toListError(err, "Product");
            }
            ProductPartial[]|error converted = partials.cloneWithType();
            if converted is error {
                return dsHttp:toListError(converted, "Product");
            }
            return <ProductPartialList>{items: converted, hasMore};
        }
        return <ProductList>{items, hasMore};
    }

    # Gets a product by its key.
    #
    # + id - The id of the product
    # + fields - The fields to return; the key fields are always returned
    # + return - The product, or the error response
    resource function get products/[int id](string[]? fields = ())
            returns Product|ProductPartial|dsHttp:NotFound|dsHttp:InvalidInput|dsHttp:InternalError {
        dataservice:DataserviceError? invalidFields =
            dataservice:checkFields(dataserviceProductEntity, fields);
        if invalidFields is dataservice:DataserviceError {
            return dsHttp:toQueryError(invalidFields, "Product");
        }
        Product|persist:Error item = self.persistClient->/products/[id];
        if item is persist:Error {
            return dsHttp:toGetError(item, "Product", [id]);
        }
        if fields is string[] {
            map<anydata> partial = dataservice:selectFields(item, dataserviceProductEntity, fields);
            do {
                if dataservice:isIncluded(fields, "orderItems") {
                    dataservice:Query include = dataservice:toIncludeQuery(
                            dataserviceProductEntity, "orderItems", [item], self.pageConfig);
                    stream<OrderItem, persist:Error?> includedRows = self.persistClient->/orderitems(OrderItem,
                        whereClause = include.whereClause, orderByClause = include.orderByClause,
                        limitClause = include.limitClause
                    );
                    OrderItem[] included = check from OrderItem row in includedRows
                        select row;
                    boolean includedMore = dataservice:trimToPage(included, include);
                    dataservice:attachMany(
                            partial, dataserviceProductEntity, "orderItems", included, includedMore, fields);
                }
            } on fail error err {
                return dsHttp:toGetError(err, "Product", [id]);
            }
            ProductPartial|error converted = partial.cloneWithType();
            if converted is error {
                return dsHttp:toGetError(converted, "Product", [id]);
            }
            return converted;
        }
        return item;
    }

    # Gets the order items of a product.
    #
    # + id - The id of the product
    # + filter - The conditions that the order items match
    # + sort - The fields to sort by, each descending when it starts with `-`
    # + size - The number of order items in the page
    # + offset - The number of order items to skip
    # + fields - The fields of the order items to return; the key fields are always returned
    # + return - A page of the order items, or the error response
    resource function get products/[int id]/orderItems(OrderItemFilter? filter = (),
            string[]? sort = (), int? size = (), int? offset = (), string[]? fields = ())
            returns OrderItemList|OrderItemRelatedPartialList|dsHttp:NotFound|dsHttp:InvalidInput|dsHttp:InternalError {
        dataservice:DataserviceError? invalidFields =
            dataservice:checkFields(dataserviceOrderItemEntity, fields, false);
        if invalidFields is dataservice:DataserviceError {
            return dsHttp:toQueryError(invalidFields, "OrderItem");
        }
        map<anydata> itemKey = {"id": id};
        dataservice:Query|dataservice:DataserviceError|dataservice:ConversionError query =
            dataservice:toRelatedQuery(
                dataserviceProductEntity, "orderItems", itemKey, self.pageConfig, filter, sort, size, offset);
        if query !is dataservice:Query {
            return dsHttp:toQueryError(query, "OrderItem");
        }
        stream<OrderItem, persist:Error?> rows = self.persistClient->/orderitems(OrderItem,
            whereClause = query.whereClause, orderByClause = query.orderByClause,
            limitClause = query.limitClause, offsetClause = query.offsetClause
        );
        OrderItem[]|persist:Error items = from OrderItem related in rows
            select related;
        if items is persist:Error {
            return dsHttp:toListError(items, "Product", "get related");
        }
        boolean hasMore = dataservice:trimToPage(items, query);
        if items.length() == 0 {
            Product|persist:Error item = self.persistClient->/products/[id];
            if item is persist:Error {
                return dsHttp:toGetError(item, "Product", [id], "get related");
            }
            return <OrderItemList>{items, hasMore};
        }
        if fields is string[] {
            OrderItemRelatedPartial[]|error partials = (from OrderItem related in items
                select dataservice:selectFields(related, dataserviceOrderItemEntity, fields)).cloneWithType();
            if partials is error {
                return dsHttp:toListError(partials, "Product", "get related");
            }
            return <OrderItemRelatedPartialList>{items: partials, hasMore};
        }
        return <OrderItemList>{items, hasMore};
    }

    # Creates one or more products.
    #
    # + payload - The product, or the products, to create
    # + return - The created product or products, or the error response
    resource function post products(ProductInsert|ProductInsert[] payload)
            returns ProductCreated|ProductListCreated|dsHttp:InvalidInput|dsHttp:Conflict|dsHttp:ConstraintViolation|dsHttp:InternalError {
        ProductInsert[] values = payload is ProductInsert[] ? payload : [payload];
        dataservice:DataserviceError? tooMany = dataservice:checkCreateSize(values.length(), self.pageConfig);
        if tooMany is dataservice:DataserviceError {
            return <dsHttp:InvalidInput>{body: tooMany};
        }
        Product[] items = [];
        if values.length() > 0 {
            do {
                transaction {
                    int[] keys = check self.persistClient->/products.post(values);
                    dataservice:KeyValue[][] keyValues = from int key in keys
                        select [key];
                    dataservice:Query query = dataservice:toKeysQuery(dataserviceProductEntity, keyValues);
                    stream<Product, persist:Error?> stored = self.persistClient->/products(Product,
                        whereClause = query.whereClause, orderByClause = query.orderByClause
                    );
                    Product[] rows = check from Product item in stored
                        select item;
                    check dataservice:orderByKeys(rows, dataserviceProductEntity, keyValues);
                    items = rows;
                    check commit;
                }
            } on fail error err {
                return dsHttp:toCreateError(err, "Product");
            }
        }
        if payload is ProductInsert[] {
            return <ProductListCreated>{body: {items, hasMore: false}};
        }
        Product created = items[0];
        return <ProductCreated>{
            headers: {"Location": dsHttp:toLocation("/api/products", [created.id])},
            body: created
        };
    }

    # Updates a product by its key.
    #
    # + id - The id of the product
    # + payload - The fields of the product to update
    # + return - The updated product, or no content when it cannot be read back, or the error response
    resource function patch products/[int id](ProductUpdate payload)
            returns Product|http:NoContent|dsHttp:NotFound|dsHttp:InvalidInput|dsHttp:Conflict|dsHttp:ConstraintViolation|dsHttp:InternalError {
        Product|persist:Error item;
        if payload.length() == 0 {
            item = self.persistClient->/products/[id];
        } else {
            item = self.persistClient->/products/[id].put(payload);
        }
        if item is persist:Error {
            return dsHttp:toUpdateError(item, "Product", [id]);
        }
        return item;
    }

    # Deletes a product by its key.
    #
    # + id - The id of the product
    # + return - The deleted product, or the error response
    resource function delete products/[int id]()
            returns Product|dsHttp:NotFound|dsHttp:InvalidInput|dsHttp:ConstraintViolation|dsHttp:InternalError {
        Product|persist:Error item = self.persistClient->/products/[id].delete();
        if item is persist:Error {
            return dsHttp:toDeleteError(item, "Product", [id]);
        }
        return item;
    }
}

# Answers the errors that `ballerina/http` raises with the `DataserviceError` body.
isolated service class DataserviceErrorInterceptor {
    *http:ResponseErrorInterceptor;

    isolated remote function interceptResponseError(error err, http:RequestContext ctx, http:Response response)
            returns http:NextService? {
        dsHttp:setErrorBody(response, err);
        // The response is changed in place; an error return would add a 500 response to the OpenAPI definition.
        http:NextService|error? next = ctx.next();
        return next is http:NextService ? next : ();
    }
}
