SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[synthea_person_10](
	[person_id] [int] NOT NULL,
	[gender_concept_id] [int] NOT NULL,
	[year_of_birth] [int] NOT NULL,
	[month_of_birth] [int] NULL,
	[day_of_birth] [int] NULL,
	[birth_datetime] [datetime] NULL,
	[race_concept_id] [int] NOT NULL,
	[ethnicity_concept_id] [int] NOT NULL,
	[location_id] [int] NULL,
	[provider_id] [int] NULL,
	[care_site_id] [int] NULL,
	[person_source_value] [varchar](50) NULL,
	[gender_source_value] [varchar](50) NULL,
	[gender_source_concept_id] [int] NULL,
	[race_source_value] [varchar](50) NULL,
	[race_source_concept_id] [int] NULL,
	[ethnicity_source_value] [varchar](50) NULL,
	[ethnicity_source_concept_id] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[synthea_person_10] ADD  CONSTRAINT [PK_synthea_person_10] PRIMARY KEY CLUSTERED 
(
	[person_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
