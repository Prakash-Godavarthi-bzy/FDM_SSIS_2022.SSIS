--The same operations can be also performed using T-SQL commands. You can rebuild the previous index, using the ALTER INDEX REBUILD T-SQL command, with the ability to set the different index creation options, such as the FILL FACTOR, ONLINE or PAD_INDEX, as shown in below:

ALTER INDEX [IX_STD_Evaluation_STD_Course_Grade] ON [dbo].[STD_Evaluation] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
--Also, the index can be reorganized, using the ALTER INDEX REORGANIZE T-SQL command below:

ALTER INDEX [IX_STD_Evaluation_STD_Course_Grade] ON [dbo].[STD_Evaluation] REORGANIZE  WITH ( LOB_COMPACTION = ON )
GO

--You can also organize all the table indexes, by providing the ALTER INDEX REORGANIZE T-SQL statement with ALL option, instead of the index name, as in the T-SQL statement below:

ALTER INDEX ALL ON [dbo].[STD_Evaluation]
REORGANIZE ;   
GO

--And rebuild all the table indexes, by providing the ALTER INDEX REBUILD T-SQL statement with ALL option, instead of the index name, as in the T-SQL statement below:

ALTER INDEX ALL ON [dbo].[STD_Evaluation] 
REBUILD WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

-----------------------------------------------------------------

Update STATISTICS dbo.FACTAllocationsV1_History  WITH FULLSCAN, COLUMNS
	DBCC SHOW_STATISTICS

	DBCC SHOW_STATISTICS('FACTAllocationsV1_History'
                     ,PK_FACTAllocationsV1_History) WITH STAT_HEADER;

	Update STATISTICS dbo.FACTAllocationsV1_History