/* 1. Tổng số vụ khủng bố theo năm */
SELECT 
    {[Measures].[Incident Count]} ON COLUMNS, 
    [Dim Date].[Year].[Year] ON ROWS 
FROM [Terrorism];

/* 2. Chi tiết số vụ khủng bố theo từng tháng trong năm 1990 */
SELECT 
    {[Measures].[Incident Count]} ON COLUMNS, 
    {[Dim Date].[Month].[Month]} ON ROWS 
FROM [Terrorism]
WHERE [Dim Date].[Year].[1990];

/* 3. Số vụ khủng bố và số thương vong theo các khu vực trong năm 1994 */

-- Start Named Set: Câu 3
CREATE DYNAMIC SET CURRENTCUBE.[Câu 3]
AS ORDER ({ ([Dim Location].[Region Name].[Region Name] ) },[Measures].[Incident Count], DESC ), DISPLAY_FOLDER = 'Named Set';
-- End Named Set

SELECT 
    { [Measures].[Incident Count], [Measures].[Kills], [Measures].[Wounds] } ON COLUMNS, 
    ( [Câu 3] ) ON ROWS
 FROM [Terrorism]
 WHERE [Dim Date].[Year].&[1994];

/* 4. Liệt kê băng nhóm, tổ chức khủng bố lớn trên thế giới làm hơn 5000 người chết */

-- Start Named Set: Câu 4
CREATE DYNAMIC SET CURRENTCUBE.[Câu 4]
AS FILTER(
    [Dim G Name].[G Name].[G Name], 
    [Measures].[Kills] > 5000
), DISPLAY_FOLDER = 'Named Set'; 
-- End Named Set

SELECT 
    { [Measures].[Kills], [Measures].[Incident Count] } ON COLUMNS, 
    (( [Câu 4] )) ON ROWS
FROM [Terrorism];

/* 5. Top 5 thành phố có số vụ khủng bố cao nhất trong năm 2010 */

-- Start Named Set: Câu 5
CREATE DYNAMIC SET CURRENTCUBE.[Câu 5]
AS TOPCOUNT(
    [Dim Location].[City Name].[City Name], 
    5, 
    [Measures].[Incident Count]
), DISPLAY_FOLDER = 'Named Set'; 
-- End Named Set

SELECT 
    (( [Câu 5] )) ON ROWS,
    {[Measures].[Incident Count]} ON COLUMNS
FROM [Terrorism]
WHERE ([Dim Date].[Year].&[2010]);

/* 6. Phân tích Tháng Có Số Vụ Tấn Công Tăng Đột Biến */

-- Start Named Set: Câu 6
CREATE DYNAMIC SET CURRENTCUBE.[Câu 6]
AS ORDER(
    FILTER(
        [Dim Date].[Month].[Month], 
        [Measures].[Monthly Incident Growth Rate] > 0.5
    ),
    [Measures].[Monthly Incident Growth Rate],
    DESC
), DISPLAY_FOLDER = 'Named Set';              
-- End Named Set

-- Start Calculated Member: [Monthly Incident Growth Rate]
CREATE MEMBER CURRENTCUBE.[Measures].[Monthly Incident Growth Rate]
 AS IIF(
  ([Measures].[Incident Count], [Dim Date].[Month].CurrentMember.PrevMember) = 0,
  NULL,
  ([Measures].[Incident Count], [Dim Date].[Month].CurrentMember)
  / ([Measures].[Incident Count], [Dim Date].[Month].CurrentMember.PrevMember) - 1
), 
FORMAT_STRING = "Percent", 
VISIBLE = 1 ,  DISPLAY_FOLDER = 'Calculated Member' ,  ASSOCIATED_MEASURE_GROUP = 'Fact Incident'  ;  
-- End Calculated Member
-- Start Calculated Member: [Previous Month Incident Count]
CREATE MEMBER CURRENTCUBE.[Measures].[Previous Month Incident Count]
 AS ([Measures].[Incident Count], [Dim Date].[Month].CurrentMember.PrevMember), 
VISIBLE = 1 ,  DISPLAY_FOLDER = 'Calculated Member' ,  ASSOCIATED_MEASURE_GROUP = 'Fact Incident'  ; 
-- End Calculated Member

SELECT
    {[Measures].[Previous Month Incident Count], [Measures].[Incident Count], [Measures].[Monthly Incident Growth Rate]} ON COLUMNS,
    (( [Câu 6] )) ON ROWS
FROM [Terrorism];

/* 7. Phần trăm các vụ tấn công khủng bố trên mỗi châu lục so với tổng tất cả các vụ khủng bố */

-- Start Named Set: Câu 7
CREATE DYNAMIC SET CURRENTCUBE.[Câu 7]
AS TOPCOUNT(
    [Dim Location].[Region Name].[Region Name],
    10,
    [Measures].[Incident Count]
), DISPLAY_FOLDER = 'Named Set'  ;  
-- End Named Set

-- Start Calculated Member: [Total Incidents in Year]
CREATE MEMBER CURRENTCUBE.[Measures].[Total Incidents in Year]
 AS SUM({[Dim Location].[Region Name].[All]},([Measures].[Incident Count])), 
VISIBLE = 1 ,  DISPLAY_FOLDER = 'Calculated Member' ,  ASSOCIATED_MEASURE_GROUP = 'Fact Incident';  
-- End Calculated Member
-- Start Calculated Member: [Percentage of Total Incidents]
CREATE MEMBER CURRENTCUBE.[Measures].[Percentage of Total Incidents]
 AS IIF(
    [Measures].[Total Incidents in Year] = 0,
    NULL,
    ([Measures].[Incident Count] / [Measures].[Total Incidents in Year])
), 
FORMAT_STRING = "Percent", 
VISIBLE = 1 ,  DISPLAY_FOLDER = 'Calculated Member' ,  ASSOCIATED_MEASURE_GROUP = 'Fact Incident'; 
-- End Calculated Member

SELECT
  { [Measures].[Incident Count],[Measures].[Percentage of Total Incidents] } ON COLUMNS,
  (( [Câu 7] )) ON ROWS
FROM [Terrorism];

/* 8. Top 30 Nhóm Khủng Bố Với Tỷ Lệ Thương Vong và xác suất thành công cao nhất (> 70%) */

-- Start Named Set: Câu 8
CREATE DYNAMIC SET CURRENTCUBE.[Câu 8]
AS TOPCOUNT(
    FILTER(
        [Dim G Name].[G Name].[G Name],
        [Measures].[Casualty Rate] > 30 AND [Measures].[Success Rate] > 0.7
    ), 
    30, 
    [Measures].[Casualty Rate] + [Measures].[Success Rate]
), DISPLAY_FOLDER = 'Named Set';              
-- End Named Set

-- Start Calculated Member: Casualty Rate
CREATE MEMBER CURRENTCUBE.[Measures].[Casualty Rate]
 AS ([Measures].[Kills] + [Measures].[Wounds]) / [Measures].[Incident Count], 
NON_EMPTY_BEHAVIOR = { [Incident Count] }, 
VISIBLE = 1 ,  DISPLAY_FOLDER = 'Calculated Member' ,  ASSOCIATED_MEASURE_GROUP = 'Fact Incident'  ; 
-- End Calculated Member

SELECT  {[Measures].[Casualty Rate], [Measures].[Success Rate],[Measures].[Incident Count]} ON COLUMNS,
    (( [Câu 8] )) ON ROWS
FROM [Terrorism];

/* 9. Tìm tất cả các vụ tấn công tự sát có mục tiêu là chính phủ */

-- Start Named Set: Câu 9
CREATE DYNAMIC SET CURRENTCUBE.[Câu 9]
AS FILTER(
    NonEmptyCrossjoin([Dim G Name].[G Name].[G Name], [Dim Target Type].[Target Type].[Target Type], [Dim Attack Type].[Attack Type].[Attack Type]),
    INSTR([Dim Target Type].[Target Type].CurrentMember.Properties("Member_Caption"), 'Government') > 0 
    AND [Measures].[Suicide] > 0
    AND [Measures].[Suicide] = [Measures].[Incident Count] 
), DISPLAY_FOLDER = 'Named Set';           
-- End Named Set

-- Start Calculated Member: Success Rate
CREATE MEMBER CURRENTCUBE.[Measures].[Success Rate]
 AS [Measures].[Success]/[Measures].[Incident Count], 
FORMAT_STRING = "Percent", 
VISIBLE = 1 ,  DISPLAY_FOLDER = 'Calculated Member' ,  ASSOCIATED_MEASURE_GROUP = 'Fact Incident'; 
-- End Calculated Member

SELECT  {[Measures].[Incident Count], [Measures].[Success Rate], [Measures].[Suicide]} ON COLUMNS,
    (( [Câu 9] )) ON ROWS
FROM [Terrorism];

/* 10. Tổng hợp số thương vong trong vụ tấn công 11/9 tại Mỹ */

-- Start Named Set: Câu 10
CREATE DYNAMIC SET CURRENTCUBE.[Câu 10]
AS NONEMPTY(
    DESCENDANTS(
        [Dim Location].[Hierarchy].[Region Name].[North America].[United States],
        [Dim Location].[Hierarchy].[City],
        SELF_AND_AFTER
    ), 
    { [Measures].[Incident Count], [Measures].[Wounds], [Measures].[Kills] }
), DISPLAY_FOLDER = 'Named Set'  ; 
-- End Named Set

SELECT 
    { [Measures].[Incident Count], [Measures].[Wounds], [Measures].[Kills] } ON COLUMNS,
    (( [Câu 10] )) ON ROWS 
FROM [Terrorism]
WHERE 
    ([Dim Date].[Day].&[20010911],
    [Dim Attack Type].[Attack Type].&[Hijacking]);

/* 11. Top 10 các thành phố (cùng các khu vực tương ứng) có số vụ khủng bố liên quan đến bắt cóc cao nhất */

-- Start Named Set: Câu 11
CREATE DYNAMIC SET CURRENTCUBE.[Câu 11]
AS TOPCOUNT(
    [Dim Location].[Region Name].[Region Name] * [Dim Location].[City Name].[City Name] * [Dim Attack Type].[Attack Type].&[Hostage Taking (Kidnapping)], 
    10, 
    [Measures].[Incident Count]
), DISPLAY_FOLDER = 'Named Set'; 
-- End Named Set

SELECT 
    (( [Câu 11] )) ON ROWS,
    {[Measures].[Incident Count]} ON COLUMNS
FROM [Terrorism];

/* 12. Thông tin vụ đánh bom cảm tử tại London 7/7 */

-- Start Named Set: Câu 12
CREATE DYNAMIC SET CURRENTCUBE.[Câu 12]
 AS { NONEMPTY([Dim Date].[Day].&[20050707] * [Dim Attack Type].[Attack Type].[Attack Type]) }, DISPLAY_FOLDER = 'Named Set'  ; 
-- End Named Set

SELECT 
    { [Measures].[Incident Count], [Measures].[Kills], [Measures].[Wounds],  [Measures].[Success], [Measures].[Suicide] } ON COLUMNS,
    (( [Câu 12] )) ON ROWS
FROM [Terrorism]
WHERE [Dim Location].[Hierarchy].[ProvinceState].[England].[Brixton];

/* 13. Trung bình số người bị giết trong các vụ khủng bố của mỗi quốc gia */

-- Start Named Set: Câu 13
CREATE DYNAMIC SET CURRENTCUBE.[Câu 13]
AS NONEMPTY(
    [Dim Location].[Country Name].[Country Name],
    [Measures].[Average Kills]
), DISPLAY_FOLDER = 'Named Set';         
-- End Named Set

-- Start Calculated Member: Average Kills
CREATE MEMBER CURRENTCUBE.[Measures].[Average Kills]
 AS IIf(
    [Measures].[Incident Count] = 0,
    NULL,
    [Measures].[Kills] / [Measures].[Incident Count]
), 
FORMAT_STRING = "0.00", 
VISIBLE = 1 ,  DISPLAY_FOLDER = 'Calculated Member' ,  ASSOCIATED_MEASURE_GROUP = 'Fact Incident'  ;         
-- End Calculated Member

SELECT 
    {[Measures].[Average Kills]} ON COLUMNS,
    (( [Câu 13] )) ON ROWS
FROM [Terrorism];

/* 14. So sánh số thương vong hằng năm do khủng bố */

-- Start Calculated Member: [Previous Year Casualties]
CREATE MEMBER CURRENTCUBE.[Measures].[Previous Year Casualties]
 AS ([Measures].[Kills], ParallelPeriod([Dim Date].[Year].LEVEL, 1, [Dim Date].[Year].CurrentMember)), 
VISIBLE = 1 ,  DISPLAY_FOLDER = 'Calculated Member' ,  ASSOCIATED_MEASURE_GROUP = 'Fact Incident'  ;         
-- End Calculated Member
-- Start Calculated Member: [Percent Change]
CREATE MEMBER CURRENTCUBE.[Measures].[Percent Change]
 AS IIf(
    [Measures].[Previous Year Casualties] IS NULL OR [Measures].[Previous Year Casualties] = 0, 
    NULL, 
    (([Measures].[Kills] - [Measures].[Previous Year Casualties]) / [Measures].[Previous Year Casualties])
), 
FORMAT_STRING = "Percent", 
VISIBLE = 1 ,  DISPLAY_FOLDER = 'Calculated Member' ,  ASSOCIATED_MEASURE_GROUP = 'Fact Incident'; 
-- End Calculated Member

SELECT 
    {[Measures].[Previous Year Casualties], [Measures].[Kills], [Measures].[Percent Change]} ON COLUMNS,
    [Dim Date].[Year].[Year] ON ROWS
FROM [Terrorism];

/* 15. Thống kê các loại vũ khí dùng trong các cuộc tấn công */

-- Start Named Set: Câu 15
CREATE DYNAMIC SET CURRENTCUBE.[Câu 15]
AS ORDER(
    {NONEMPTY([Dim Attack Type].[Attack Type].[Attack Type])},
    [Measures].[Incident Count],
    DESC
), DISPLAY_FOLDER = 'Named Set'; 
-- End Named Set

SELECT 
    {[Measures].[Incident Count], [Measures].[Casualty Rate]} ON COLUMNS,
    ( [Câu 15] )  ON ROWS
FROM [Terrorism];