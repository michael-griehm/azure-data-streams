SELECT
    Symbol, Max(Price) AS MaxPrice, Min(Price) AS MinPrice, System.Timestamp() AS WindowEndTime, COUNT(*) AS Cnt
INTO
    [OutputAlias]
FROM
    [eh-crypto-stream]
GROUP BY Symbol, TumblingWindow(minute, 20)

SELECT
    Symbol, Max(Price) AS MaxPrice, Min(Price) AS MinPrice, Min(CAST(EventEnqueuedUtcTime AS DATETIME)) AS MinEnqueueTime, System.Timestamp() AS WindowEndTime, COUNT(*) AS Cnt
INTO
    [OutputAlias]
FROM
    [eh-crypto-stream]
GROUP BY Symbol, TumblingWindow(Duration(hour, 1), Offset(millisecond, -1))

SELECT
    Symbol, Max(Price) AS MaxPrice, Min(Price) AS MinPrice, System.Timestamp() AS WindowEndTime, COUNT(*) AS Cnt
INTO
    [OutputAlias]
FROM
    [eh-crypto-stream]
GROUP BY Symbol, SessionWindow(minute, 5, 30)

SELECT
    Symbol, Max(Price) AS MaxPrice, Min(Price) AS MinPrice, Min(CAST(EventEnqueuedUtcTime AS DATETIME)) AS MinEnqueueTime, System.Timestamp() AS WindowEndTime, COUNT(*) AS Cnt
INTO
    [OutputAlias]
FROM
    [eh-crypto-stream]
GROUP BY Symbol, HoppingWindow(Duration(hour, 1), Hop(minute, 5), Offset(millisecond, -1))