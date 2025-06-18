CALCULATE;

         
CREATE DYNAMIC SET CURRENTCUBE.[Câu 3]
 AS ORDER ({ ([Dim Location].[Region Name].[Region Name] ) },[Measures].[Incident Count], DESC ), DISPLAY_FOLDER = 'Named Set'  ;

 
CREATE DYNAMIC SET CURRENTCUBE.[Câu 4]
 AS FILTER(
        [Dim G Name].[G Name].[G Name], 
        [Measures].[Kills] > 5000
    ), DISPLAY_FOLDER = 'Named Set'  ;

 
CREATE DYNAMIC SET CURRENTCUBE.[Câu 5]
 AS TOPCOUNT(
        [Dim Location].[City Name].[City Name], 
        5, 
        [Measures].[Incident Count]
    ), DISPLAY_FOLDER = 'Named Set'  ;

 
CREATE DYNAMIC SET CURRENTCUBE.[Câu 6]
 AS ORDER(
        FILTER(
            [Dim Date].[Month].[Month], 
            [Measures].[Monthly Incident Growth Rate] > 0.5
        ),
        [Measures].[Monthly Incident Growth Rate],
        DESC
    ), DISPLAY_FOLDER = 'Named Set'  ;

              
CREATE MEMBER CURRENTCUBE.[Measures].[Monthly Incident Growth Rate]
 AS IIF(
  ([Measures].[Incident Count], [Dim Date].[Month].CurrentMember.PrevMember) = 0,
  NULL,
  ([Measures].[Incident Count], [Dim Date].[Month].CurrentMember)
  / ([Measures].[Incident Count], [Dim Date].[Month].CurrentMember.PrevMember) - 1
), 
FORMAT_STRING = "Percent", 
VISIBLE = 1 ,  DISPLAY_FOLDER = 'Calculated Member' ,  ASSOCIATED_MEASURE_GROUP = 'Fact Incident'  ;

  
CREATE MEMBER CURRENTCUBE.[Measures].[Previous Month Incident Count]
 AS ([Measures].[Incident Count], [Dim Date].[Month].CurrentMember.PrevMember), 
VISIBLE = 1 ,  DISPLAY_FOLDER = 'Calculated Member' ,  ASSOCIATED_MEASURE_GROUP = 'Fact Incident'  ;

 
CREATE DYNAMIC SET CURRENTCUBE.[Câu 7]
 AS TOPCOUNT(
    [Dim Location].[Region Name].[Region Name],
    10,
    [Measures].[Incident Count]
  ), DISPLAY_FOLDER = 'Named Set'  ;

  
CREATE MEMBER CURRENTCUBE.[Measures].[Total Incidents in Year]
 AS SUM({[Dim Location].[Region Name].[All]},([Measures].[Incident Count])), 
VISIBLE = 1 ,  DISPLAY_FOLDER = 'Calculated Member' ,  ASSOCIATED_MEASURE_GROUP = 'Fact Incident'  ;

  
CREATE MEMBER CURRENTCUBE.[Measures].[Percentage of Total Incidents]
 AS IIF(
    [Measures].[Total Incidents in Year] = 0,
    NULL,
    ([Measures].[Incident Count] / [Measures].[Total Incidents in Year])
), 
FORMAT_STRING = "Percent", 
VISIBLE = 1 ,  DISPLAY_FOLDER = 'Calculated Member' ,  ASSOCIATED_MEASURE_GROUP = 'Fact Incident'  ;

 
CREATE DYNAMIC SET CURRENTCUBE.[Câu 8]
 AS TOPCOUNT(
        FILTER(
            [Dim G Name].[G Name].[G Name],
            [Measures].[Casualty Rate] > 30 AND [Measures].[Success Rate] > 0.7
        ), 
        30, 
        [Measures].[Casualty Rate] + [Measures].[Success Rate]
    ), DISPLAY_FOLDER = 'Named Set'  ;

              
CREATE MEMBER CURRENTCUBE.[Measures].[Casualty Rate]
 AS ([Measures].[Kills] + [Measures].[Wounds]) / [Measures].[Incident Count], 
NON_EMPTY_BEHAVIOR = { [Incident Count] }, 
VISIBLE = 1 ,  DISPLAY_FOLDER = 'Calculated Member' ,  ASSOCIATED_MEASURE_GROUP = 'Fact Incident'  ;

 
CREATE DYNAMIC SET CURRENTCUBE.[Câu 9]
 AS FILTER(
        NonEmptyCrossjoin([Dim G Name].[G Name].[G Name], [Dim Target Type].[Target Type].[Target Type], [Dim Attack Type].[Attack Type].[Attack Type]),
        INSTR([Dim Target Type].[Target Type].CurrentMember.Properties("Member_Caption"), 'Government') > 0 
        AND [Measures].[Suicide] > 0
        AND [Measures].[Suicide] = [Measures].[Incident Count] 
    ), DISPLAY_FOLDER = 'Named Set'  ;

           
CREATE MEMBER CURRENTCUBE.[Measures].[Success Rate]
 AS [Measures].[Success]/[Measures].[Incident Count], 
FORMAT_STRING = "Percent", 
VISIBLE = 1 ,  DISPLAY_FOLDER = 'Calculated Member' ,  ASSOCIATED_MEASURE_GROUP = 'Fact Incident'  ;

 
CREATE DYNAMIC SET CURRENTCUBE.[Câu 10]
 AS NONEMPTY(
        DESCENDANTS(
            [Dim Location].[Hierarchy].[Region Name].[North America].[United States],
            [Dim Location].[Hierarchy].[City],
            SELF_AND_AFTER
        ), 
        { [Measures].[Incident Count], [Measures].[Wounds], [Measures].[Kills] }
    ), DISPLAY_FOLDER = 'Named Set'  ;

 
CREATE DYNAMIC SET CURRENTCUBE.[Câu 11]
 AS TOPCOUNT(
        [Dim Location].[Region Name].[Region Name] * [Dim Location].[City Name].[City Name] * [Dim Attack Type].[Attack Type].&[Hostage Taking (Kidnapping)], 
        10, 
        [Measures].[Incident Count]
    ), DISPLAY_FOLDER = 'Named Set'  ;

 
CREATE DYNAMIC SET CURRENTCUBE.[Câu 12]
 AS { NONEMPTY([Dim Date].[Day].&[20050707] * [Dim Attack Type].[Attack Type].[Attack Type]) }, DISPLAY_FOLDER = 'Named Set'  ;

 
CREATE DYNAMIC SET CURRENTCUBE.[Câu 13]
 AS NONEMPTY(
        [Dim Location].[Country Name].[Country Name],
        [Measures].[Average Kills]
    ), DISPLAY_FOLDER = 'Named Set'  ;

         
CREATE MEMBER CURRENTCUBE.[Measures].[Average Kills]
 AS IIf(
    [Measures].[Incident Count] = 0,
    NULL,
    [Measures].[Kills] / [Measures].[Incident Count]
), 
FORMAT_STRING = "0.00", 
VISIBLE = 1 ,  DISPLAY_FOLDER = 'Calculated Member' ,  ASSOCIATED_MEASURE_GROUP = 'Fact Incident'  ;

         
CREATE MEMBER CURRENTCUBE.[Measures].[Previous Year Casualties]
 AS ([Measures].[Kills], ParallelPeriod([Dim Date].[Year].LEVEL, 1, [Dim Date].[Year].CurrentMember)), 
VISIBLE = 1 ,  DISPLAY_FOLDER = 'Calculated Member' ,  ASSOCIATED_MEASURE_GROUP = 'Fact Incident'  ;

         
CREATE MEMBER CURRENTCUBE.[Measures].[Percent Change]
 AS IIf(
    [Measures].[Previous Year Casualties] IS NULL OR [Measures].[Previous Year Casualties] = 0, 
    NULL, 
    (([Measures].[Kills] - [Measures].[Previous Year Casualties]) / [Measures].[Previous Year Casualties])
), 
FORMAT_STRING = "Percent", 
VISIBLE = 1 ,  DISPLAY_FOLDER = 'Calculated Member' ,  ASSOCIATED_MEASURE_GROUP = 'Fact Incident'  ;

 
CREATE DYNAMIC SET CURRENTCUBE.[Câu 15]
 AS ORDER(
        {NONEMPTY([Dim Attack Type].[Attack Type].[Attack Type])},
        [Measures].[Incident Count],
        DESC
    ), DISPLAY_FOLDER = 'Named Set'  ;