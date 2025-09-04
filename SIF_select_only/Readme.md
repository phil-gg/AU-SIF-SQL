# Explanation of Select Only folder and files

SQL scripts here have filenames that each align with one table from **"Drop-then-Create-SIF-tables.sql"**.
They select the data for the target table only, without inserting them into any target SIF tables.

The "tables list" files track all the scripts to be built, and *(with "xxx.yyy" filename prefix)* recommends the order in which  to complete the mappings, and documents the dependency order in which data insert must occur.
The status table below is a copy-paste of "tables list" columns A to E into [tablesgenerator.com/markdown_tables](https://www.tablesgenerator.com/markdown_tables).

## Current state of mapping

| Create Table Order | TableName | Mapped Yet? | Group | Area |
|-------------------:|:----------|:-----------:|------:|:-----|
| 1 | cdm_demo_gold.Dim0StaffEmploymentStatus | ✅ | 0 | Tables populated by SIF specification |
| 2 | cdm_demo_gold.Dim0ElectronicIdType | ✅ | 0 | Tables populated by SIF specification |
| 3 | cdm_demo_gold.Dim0NameUsageType | ✅ | 0 | Tables populated by SIF specification |
| 4 | cdm_demo_gold.Dim0YesNoType | ✅ | 0 | Tables populated by SIF specification |
| 5 | cdm_demo_gold.Dim0IndigenousStatus | ✅ | 0 | Tables populated by SIF specification |
| 6 | cdm_demo_gold.Dim0SexCode | ✅ | 0 | Tables populated by SIF specification |
| 7 | cdm_demo_gold.Dim0BirthdateVerification | ✅ | 0 | Tables populated by SIF specification |
| 8 | cdm_demo_gold.Dim0StateTerritoryCode | ✅ | 0 | Tables populated by SIF specification |
| 9 | cdm_demo_gold.Dim0AustralianCitizenshipStatus | ✅ | 0 | Tables populated by SIF specification |
| 10 | cdm_demo_gold.Dim0EnglishProficiency | ✅ | 0 | Tables populated by SIF specification |
| 11 | cdm_demo_gold.Dim0DwellingArrangement | ✅ | 0 | Tables populated by SIF specification |
| 12 | cdm_demo_gold.Dim0ReligionType | ✅ | 0 | Tables populated by SIF specification |
| 13 | cdm_demo_gold.Dim0PermanentResidentStatus | ✅ | 0 | Tables populated by SIF specification |
| 14 | cdm_demo_gold.Dim0VisaStudyEntitlement | ✅ | 0 | Tables populated by SIF specification |
| 15 | cdm_demo_gold.Dim0ImmunisationCertificateStatus | ✅ | 0 | Tables populated by SIF specification |
| 16 | cdm_demo_gold.Dim0CulturalEthnicGroups | ✅ | 0 | Tables populated by SIF specification |
| 17 | cdm_demo_gold.Dim0MaritalStatus | ✅ | 0 | Tables populated by SIF specification |
| 18 | cdm_demo_gold.Dim0AddressType | ✅ | 0 | Tables populated by SIF specification |
| 19 | cdm_demo_gold.Dim0AddressRole | ✅ | 0 | Tables populated by SIF specification |
| 20 | cdm_demo_gold.Dim0SpatialUnitType | ✅ | 0 | Tables populated by SIF specification |
| 21 | cdm_demo_gold.Dim0PhoneNumberType | ✅ | 0 | Tables populated by SIF specification |
| 22 | cdm_demo_gold.Dim0EmailType | ✅ | 0 | Tables populated by SIF specification |
| 23 | cdm_demo_gold.Dim0AlertMessageType | ✅ | 0 | Tables populated by SIF specification |
| 24 | cdm_demo_gold.Dim0MedicalSeverity | ✅ | 0 | Tables populated by SIF specification |
| 25 | cdm_demo_gold.Dim0DisabilityNCCDCategory | ✅ | 0 | Tables populated by SIF specification |
| 26 | cdm_demo_gold.Dim0PrePrimaryEducationHours | ✅ | 0 | Tables populated by SIF specification |
| 27 | cdm_demo_gold.Dim0SchoolEnrollmentType | ✅ | 0 | Tables populated by SIF specification |
| 28 | cdm_demo_gold.Dim0FFPOSStatusCode | ✅ | 0 | Tables populated by SIF specification |
| 29 | cdm_demo_gold.Dim0DisabilityLevelOfAdjustment | ✅ | 0 | Tables populated by SIF specification |
| 30 | cdm_demo_gold.Dim0BoardingStatus | ✅ | 0 | Tables populated by SIF specification |
| 31 | cdm_demo_gold.Dim0EmploymentType | ✅ | 0 | Tables populated by SIF specification |
| 32 | cdm_demo_gold.Dim0SchoolEducationLevelType | ✅ | 0 | Tables populated by SIF specification |
| 33 | cdm_demo_gold.Dim0NonSchoolEducationType | ✅ | 0 | Tables populated by SIF specification |
| 34 | cdm_demo_gold.Dim0EducationAgencyType | ✅ | 0 | Tables populated by SIF specification |
| 35 | cdm_demo_gold.Dim0OperationalStatus | ✅ | 0 | Tables populated by SIF specification |
| 36 | cdm_demo_gold.Dim0SchoolLevelType | ✅ | 0 | Tables populated by SIF specification |
| 37 | cdm_demo_gold.Dim0SchoolFocusCode | ✅ | 0 | Tables populated by SIF specification |
| 38 | cdm_demo_gold.Dim0ARIAClass | ✅ | 0 | Tables populated by SIF specification |
| 39 | cdm_demo_gold.Dim0SessionType | ✅ | 0 | Tables populated by SIF specification |
| 40 | cdm_demo_gold.Dim0YearLevelCode | ✅ | 0 | Tables populated by SIF specification |
| 41 | cdm_demo_gold.Dim0FederalElectorateList | ✅ | 0 | Tables populated by SIF specification |
| 42 | cdm_demo_gold.Dim0SchoolSectorCode | ✅ | 0 | Tables populated by SIF specification |
| 43 | cdm_demo_gold.Dim0SystemicStatus | ✅ | 0 | Tables populated by SIF specification |
| 44 | cdm_demo_gold.Dim0SchoolSystemType | ✅ | 0 | Tables populated by SIF specification |
| 45 | cdm_demo_gold.Dim0SchoolGeographicLocationType | ✅ | 0 | Tables populated by SIF specification |
| 46 | cdm_demo_gold.Dim0SchoolCoEdStatus | ✅ | 0 | Tables populated by SIF specification |
| 47 | cdm_demo_gold.Dim0AusTimeZoneList | ✅ | 0 | Tables populated by SIF specification |
| 48 | cdm_demo_gold.Dim0PartyType | ✅ | 0 | Tables populated by SIF specification |
| 49 | cdm_demo_gold.Dim0AuthenticationSource | ✅ | 0 | Tables populated by SIF specification |
| 50 | cdm_demo_gold.Dim0EncryptionAlgorithm | ✅ | 0 | Tables populated by SIF specification |
| 51 | cdm_demo_gold.Dim0PermissionCategoryCode | ✅ | 0 | Tables populated by SIF specification |
| 52 | cdm_demo_gold.Dim0PermissionYesNoType | ✅ | 0 | Tables populated by SIF specification |
| 53 | cdm_demo_gold.Dim0StaffActivity | ✅ | 0 | Tables populated by SIF specification |
| 54 | cdm_demo_gold.Dim0RelationshipToStudentType | ✅ | 0 | Tables populated by SIF specification |
| 55 | cdm_demo_gold.Dim0ParentRelationshipStatus | ✅ | 0 | Tables populated by SIF specification |
| 56 | cdm_demo_gold.Dim0ContactSourceType | ✅ | 0 | Tables populated by SIF specification |
| 57 | cdm_demo_gold.Dim0ContactMethod | ✅ | 0 | Tables populated by SIF specification |
| 58 | cdm_demo_gold.Dim0CodesetForOtherCodeListType | ✅ | 0 | Tables populated by SIF specification |
| 59 | cdm_demo_gold.Dim0EnrollmentTimeFrame | ✅ | 0 | Tables populated by SIF specification |
| 60 | cdm_demo_gold.Dim0EnrollmentEntryType | ✅ | 0 | Tables populated by SIF specification |
| 61 | cdm_demo_gold.Dim0EnrollmentExitWithdrawalType | ✅ | 0 | Tables populated by SIF specification |
| 62 | cdm_demo_gold.Dim0EnrollmentExitWithdrawalStatus | ✅ | 0 | Tables populated by SIF specification |
| 63 | cdm_demo_gold.Dim0StudentSchoolEnrollmentOtherCodeField | ✅ | 0 | Tables populated by SIF specification |
| 64 | cdm_demo_gold.Dim0FullTimePartTimeStatusCode | ✅ | 0 | Tables populated by SIF specification |
| 65 | cdm_demo_gold.Dim0PublicSchoolCatchmentStatus | ✅ | 0 | Tables populated by SIF specification |
| 66 | cdm_demo_gold.Dim0StudentSchoolEnrollmentRecordClosureReason | ✅ | 0 | Tables populated by SIF specification |
| 67 | cdm_demo_gold.Dim0StudentSchoolEnrollmentPromotionStatus | ✅ | 0 | Tables populated by SIF specification |
| 68 | cdm_demo_gold.Dim0TravelMode | ✅ | 0 | Tables populated by SIF specification |
| 69 | cdm_demo_gold.Dim0TravelAccompaniment | ✅ | 0 | Tables populated by SIF specification |
| 70 | cdm_demo_gold.Dim0StudentGroupCategoryCode | ✅ | 0 | Tables populated by SIF specification |
| 71 | cdm_demo_gold.Dim0AbstractContentType | ✅ | 0 | Tables populated by SIF specification |
| 72 | cdm_demo_gold.Dim0AustralianCurriculumStrand | ✅ | 0 | Tables populated by SIF specification |
| 73 | cdm_demo_gold.Dim0TermInfoSessionType | ✅ | 0 | Tables populated by SIF specification |
| 74 | cdm_demo_gold.Dim0EquipmentType | ✅ | 0 | Tables populated by SIF specification |
| 75 | cdm_demo_gold.Dim0OwnerOrLocationSIF_RefObject | ✅ | 0 | Tables populated by SIF specification |
| 76 | cdm_demo_gold.Dim0ResourceType | ✅ | 0 | Tables populated by SIF specification |
| 77 | cdm_demo_gold.Dim0YesNoOnly | ✅ | 0 | Tables populated by SIF specification |
| 78 | cdm_demo_gold.Dim0AcademicYearEntryType | ✅ | 0 | Tables populated by SIF specification |
| 79 | cdm_demo_gold.Dim0TeacherCoverCredit | ✅ | 0 | Tables populated by SIF specification |
| 80 | cdm_demo_gold.Dim0TeacherCoverSupervision | ✅ | 0 | Tables populated by SIF specification |
| 81 | cdm_demo_gold.Dim0ScheduledActivityType | ✅ | 0 | Tables populated by SIF specification |
| 82 | cdm_demo_gold.Dim0TimeTableChangeType | ✅ | 0 | Tables populated by SIF specification |
| 83 | cdm_demo_gold.Dim0MediumOfInstruction | ✅ | 0 | Tables populated by SIF specification |
| 84 | cdm_demo_gold.Dim0LanguageOfInstruction | ✅ | 0 | Tables populated by SIF specification |
| 85 | cdm_demo_gold.Dim0ReceivingLocationOfInstruction | ✅ | 0 | Tables populated by SIF specification |
| 86 | cdm_demo_gold.Dim0SectionInfoOtherCodeField | ✅ | 0 | Tables populated by SIF specification |
| 87 | cdm_demo_gold.Dim1Country | ✅ | 1 | eMinerva sourced reference data |
| 88 | cdm_demo_gold.Dim1Languages | ✅ | 1 | eMinerva sourced reference data |
| 89 | cdm_demo_gold.Dim1VisaSubClass | ✅ | 1 | eMinerva sourced reference data |
| 90 | cdm_demo_gold.Dim1StaffPersonal | ✅ | 2 | StaffPersonal |
| 91 | cdm_demo_gold.Dim1StaffHouseholdContactInfo |  | 2 | StaffPersonal |
| 100 | cdm_demo_gold.Dim2StaffList |  | 2 | StaffPersonal |
| 101 | cdm_demo_gold.Dim2StaffElectronicIdList |  | 2 | StaffPersonal |
| 102 | cdm_demo_gold.Dim2StaffOtherIdList |  | 2 | StaffPersonal |
| 103 | cdm_demo_gold.Dim2StaffNames | ✅ | 2 | StaffPersonal |
| 104 | cdm_demo_gold.Dim2StaffDemographics |  | 2 | StaffPersonal |
| 105 | cdm_demo_gold.Bridge2StaffCountriesOfCitizenship |  | 2 | StaffPersonal |
| 106 | cdm_demo_gold.Bridge2StaffCountriesOfResidency |  | 2 | StaffPersonal |
| 107 | cdm_demo_gold.Bridge2StaffLanguages |  | 2 | StaffPersonal |
| 108 | cdm_demo_gold.Dim2StaffReligiousEvent |  | 2 | StaffPersonal |
| 109 | cdm_demo_gold.Dim2StaffPassport |  | 2 | StaffPersonal |
| 110 | cdm_demo_gold.Dim2StaffAddressList |  | 2 | StaffPersonal |
| 111 | cdm_demo_gold.Dim2StaffPhoneNumberList |  | 2 | StaffPersonal |
| 112 | cdm_demo_gold.Dim2StaffEmailList |  | 2 | StaffPersonal |
| 113 | cdm_demo_gold.Bridge2StaffHouseholdContactInfo |  | 2 | StaffPersonal |
| 114 | cdm_demo_gold.Dim2StaffHouseholdContactAddressList |  | 2 | StaffPersonal |
| 115 | cdm_demo_gold.Dim2StaffHouseholdContactPhoneNumberList |  | 2 | StaffPersonal |
| 116 | cdm_demo_gold.Dim2StaffHouseholdContactEmailList |  | 2 | StaffPersonal |
| 117 | cdm_demo_gold.Dim2StaffMostRecentNAPLANClassList |  | 2 | StaffPersonal |
| 193 | cdm_demo_gold.Dim4StaffPersonalMostRecent |  | 2 | StaffPersonal |
| 96 | cdm_demo_gold.Dim1LEAInfo | ✅ | 3 | LEAInfo |
| 153 | cdm_demo_gold.Dim2LEAAddressList |  | 3 | LEAInfo |
| 154 | cdm_demo_gold.Dim2LEAPhoneNumberList |  | 3 | LEAInfo |
| 155 | cdm_demo_gold.Dim2LEAContactInfo |  | 3 | LEAInfo |
| 159 | cdm_demo_gold.Dim3LEAContactAddressList |  | 3 | LEAInfo |
| 160 | cdm_demo_gold.Dim3LEAContactPhoneNumberList |  | 3 | LEAInfo |
| 161 | cdm_demo_gold.Dim3LEAContactEmailList |  | 3 | LEAInfo |
| 156 | cdm_demo_gold.Dim2SchoolInfo | ✅ | 4 | SchoolInfo |
| 162 | cdm_demo_gold.Dim3SchoolACARAIdList |  | 4 | SchoolInfo |
| 163 | cdm_demo_gold.Dim3SchoolOtherIdList |  | 4 | SchoolInfo |
| 164 | cdm_demo_gold.Dim3SchoolFocus |  | 4 | SchoolInfo |
| 165 | cdm_demo_gold.Dim3SchoolAddressList |  | 4 | SchoolInfo |
| 166 | cdm_demo_gold.Dim3SchoolPhoneNumberList |  | 4 | SchoolInfo |
| 167 | cdm_demo_gold.Dim3SchoolEmailList |  | 4 | SchoolInfo |
| 168 | cdm_demo_gold.Dim3SchoolPrincipalPhoneNumberList |  | 4 | SchoolInfo |
| 169 | cdm_demo_gold.Dim3SchoolPrincipalEmailList |  | 4 | SchoolInfo |
| 170 | cdm_demo_gold.Dim3SchoolContactInfo |  | 4 | SchoolInfo |
| 171 | cdm_demo_gold.Dim3SchoolCampus |  | 4 | SchoolInfo |
| 172 | cdm_demo_gold.Dim3SchoolGroup |  | 4 | SchoolInfo |
| 173 | cdm_demo_gold.Dim3SchoolYearLevels |  | 4 | SchoolInfo |
| 174 | cdm_demo_gold.Dim3SchoolEnrollmentByYearLevel |  | 4 | SchoolInfo |
| 195 | cdm_demo_gold.Dim4SchoolContactAddressList |  | 4 | SchoolInfo |
| 196 | cdm_demo_gold.Dim4SchoolContactPhoneNumberList |  | 4 | SchoolInfo |
| 197 | cdm_demo_gold.Dim4SchoolContactEmailList |  | 4 | SchoolInfo |
| 92 | cdm_demo_gold.Dim1StudentPersonal | ✅ | 5 | StudentPersonal |
| 93 | cdm_demo_gold.Dim1StudentHouseholdContactInfo |  | 5 | StudentPersonal |
| 118 | cdm_demo_gold.Dim2StudentList |  | 5 | StudentPersonal |
| 119 | cdm_demo_gold.Dim2StudentAlertMessages |  | 5 | StudentPersonal |
| 120 | cdm_demo_gold.Dim2StudentMedicalAlertMessages |  | 5 | StudentPersonal |
| 121 | cdm_demo_gold.Dim2StudentElectronicIdList |  | 5 | StudentPersonal |
| 122 | cdm_demo_gold.Dim2StudentOtherIdList |  | 5 | StudentPersonal |
| 123 | cdm_demo_gold.Dim2StudentNames |  | 5 | StudentPersonal |
| 124 | cdm_demo_gold.Dim2StudentDemographics |  | 5 | StudentPersonal |
| 125 | cdm_demo_gold.Bridge2StudentCountriesOfCitizenship |  | 5 | StudentPersonal |
| 126 | cdm_demo_gold.Bridge2StudentCountriesOfResidency |  | 5 | StudentPersonal |
| 127 | cdm_demo_gold.Bridge2StudentLanguages |  | 5 | StudentPersonal |
| 128 | cdm_demo_gold.Dim2StudentReligiousEvent |  | 5 | StudentPersonal |
| 129 | cdm_demo_gold.Dim2StudentPassport |  | 5 | StudentPersonal |
| 130 | cdm_demo_gold.Dim2StudentAddressList |  | 5 | StudentPersonal |
| 131 | cdm_demo_gold.Dim2StudentPhoneNumberList |  | 5 | StudentPersonal |
| 132 | cdm_demo_gold.Dim2StudentEmailList |  | 5 | StudentPersonal |
| 133 | cdm_demo_gold.Bridge2StudentHouseholdContactInfo |  | 5 | StudentPersonal |
| 134 | cdm_demo_gold.Dim2StudentHouseholdContactAddressList |  | 5 | StudentPersonal |
| 135 | cdm_demo_gold.Dim2StudentHouseholdContactPhoneNumberList |  | 5 | StudentPersonal |
| 136 | cdm_demo_gold.Dim2StudentHouseholdContactEmailList |  | 5 | StudentPersonal |
| 194 | cdm_demo_gold.Dim4StudentPersonalMostRecent |  | 5 | StudentPersonal |
| 180 | cdm_demo_gold.Fact3StudentSchoolEnrollment | ✅ | 6 | StudentSchoolEnrollment |
| 210 | cdm_demo_gold.Fact4StudentSchoolEnrollmentOtherCodes |  | 6 | StudentSchoolEnrollment |
| 211 | cdm_demo_gold.Fact4StudentSchoolEnrollmentStudentGroup |  | 6 | StudentSchoolEnrollment |
| 212 | cdm_demo_gold.Fact4StudentSchoolEnrollmentPublishingPermissions |  | 6 | StudentSchoolEnrollment |
| 237 | cdm_demo_gold.Fact6StudentSubjectChoice |  | 6 | StudentSchoolEnrollment |
| 238 | cdm_demo_gold.Fact6StudentSubjectChoiceOtherCode |  | 6 | StudentSchoolEnrollment |
| 178 | cdm_demo_gold.Fact3StaffAssignment |  | 7 | StaffAssignment |
| 205 | cdm_demo_gold.Fact4StaffAssignmentActivityExtension |  | 7 | StaffAssignment |
| 206 | cdm_demo_gold.Fact4StaffAssignmentActivityExtensionOtherCode |  | 7 | StaffAssignment |
| 207 | cdm_demo_gold.Fact4StaffAssignmentYearLevels |  | 7 | StaffAssignment |
| 208 | cdm_demo_gold.Fact4StaffAssignmentCalendarSummaryList |  | 7 | StaffAssignment |
| 236 | cdm_demo_gold.Fact6StaffAssignmentSubjectList |  | 7 | StaffAssignment |
| 94 | cdm_demo_gold.Dim1StudentContactPersonal |  | 8 | StudentContactPersonal |
| 95 | cdm_demo_gold.Dim1StudentContactHouseholdContactInfo |  | 8 | StudentContactPersonal |
| 137 | cdm_demo_gold.Dim2StudentContactPersonList |  | 8 | StudentContactPersonal |
| 138 | cdm_demo_gold.Dim2StudentContactOtherIdList |  | 8 | StudentContactPersonal |
| 139 | cdm_demo_gold.Dim2StudentContactNames |  | 8 | StudentContactPersonal |
| 140 | cdm_demo_gold.Dim2StudentContactDemographics |  | 8 | StudentContactPersonal |
| 141 | cdm_demo_gold.Bridge2StudentContactCountriesOfCitizenship |  | 8 | StudentContactPersonal |
| 142 | cdm_demo_gold.Bridge2StudentContactCountriesOfResidency |  | 8 | StudentContactPersonal |
| 143 | cdm_demo_gold.Bridge2StudentContactLanguages |  | 8 | StudentContactPersonal |
| 144 | cdm_demo_gold.Dim2StudentContactReligiousEvent |  | 8 | StudentContactPersonal |
| 145 | cdm_demo_gold.Dim2StudentContactPassport |  | 8 | StudentContactPersonal |
| 146 | cdm_demo_gold.Dim2StudentContactAddressList |  | 8 | StudentContactPersonal |
| 147 | cdm_demo_gold.Dim2StudentContactPhoneNumberList |  | 8 | StudentContactPersonal |
| 148 | cdm_demo_gold.Dim2StudentContactEmailList |  | 8 | StudentContactPersonal |
| 149 | cdm_demo_gold.Bridge2StudentContactHouseholdContactInfo |  | 8 | StudentContactPersonal |
| 150 | cdm_demo_gold.Dim2StudentContactHouseholdContactAddressList |  | 8 | StudentContactPersonal |
| 151 | cdm_demo_gold.Dim2StudentContactHouseholdContactPhoneNumberList |  | 8 | StudentContactPersonal |
| 152 | cdm_demo_gold.Dim2StudentContactHouseholdContactEmailList |  | 8 | StudentContactPersonal |
| 179 | cdm_demo_gold.Fact3StudentContactRelationship |  | 9 | StudentContactRelationship |
| 209 | cdm_demo_gold.Fact4StudentContactRelationshipHouseholdList |  | 9 | StudentContactRelationship |
| 157 | cdm_demo_gold.Dim2PartyList |  | 10 | Party, Identity, PersonPicture & PrivacyObligation(s) |
| 175 | cdm_demo_gold.Dim3Identity |  | 10 | Party, Identity, PersonPicture & PrivacyObligation(s) |
| 176 | cdm_demo_gold.Dim3PersonPicture |  | 10 | Party, Identity, PersonPicture & PrivacyObligation(s) |
| 177 | cdm_demo_gold.Dim3PersonPrivacyObligationDocument |  | 10 | Party, Identity, PersonPicture & PrivacyObligation(s) |
| 198 | cdm_demo_gold.Dim4IdentityAssertions |  | 10 | Party, Identity, PersonPicture & PrivacyObligation(s) |
| 199 | cdm_demo_gold.Dim4IdentityPasswordList |  | 10 | Party, Identity, PersonPicture & PrivacyObligation(s) |
| 200 | cdm_demo_gold.Dim4PersonPicturePublishingPermissions |  | 10 | Party, Identity, PersonPicture & PrivacyObligation(s) |
| 201 | cdm_demo_gold.Dim4PersonPrivacySettingLocation |  | 10 | Party, Identity, PersonPicture & PrivacyObligation(s) |
| 202 | cdm_demo_gold.Dim4PersonPrivacyDataDomain |  | 10 | Party, Identity, PersonPicture & PrivacyObligation(s) |
| 203 | cdm_demo_gold.Dim4PersonPrivacyPermissionToParticipate |  | 10 | Party, Identity, PersonPicture & PrivacyObligation(s) |
| 204 | cdm_demo_gold.Dim4PersonPrivacyApplicableLaw |  | 10 | Party, Identity, PersonPicture & PrivacyObligation(s) |
| 228 | cdm_demo_gold.Dim5PersonPrivacyDataDomainShareWith |  | 10 | Party, Identity, PersonPicture & PrivacyObligation(s) |
| 229 | cdm_demo_gold.Dim5PersonPrivacyDataDomainDoNotShareWith |  | 10 | Party, Identity, PersonPicture & PrivacyObligation(s) |
| 97 | cdm_demo_gold.Dim1LearningResourcePackage |  | 11 | LearningResourcePackage |
| 158 | cdm_demo_gold.Dim2LearningResource |  | 12 | LearningResource |
| 181 | cdm_demo_gold.Dim3LearningResourceContacts |  | 12 | LearningResource |
| 182 | cdm_demo_gold.Dim3LearningResourceYearLevels |  | 12 | LearningResource |
| 183 | cdm_demo_gold.Dim3LearningResourceAustralianCurriculumStrandList |  | 12 | LearningResource |
| 184 | cdm_demo_gold.Dim3LearningResourceSubjectAreaList |  | 12 | LearningResource |
| 185 | cdm_demo_gold.Dim3LearningResourceMediaTypes |  | 12 | LearningResource |
| 186 | cdm_demo_gold.Dim3LearningResourceApprovals |  | 12 | LearningResource |
| 187 | cdm_demo_gold.Dim3LearningResourceEvaluations |  | 12 | LearningResource |
| 188 | cdm_demo_gold.Dim3LearningResourceComponents |  | 12 | LearningResource |
| 213 | cdm_demo_gold.Dim4LearningResourceContactNames |  | 12 | LearningResource |
| 214 | cdm_demo_gold.Dim4LearningResourceContactAddresses |  | 12 | LearningResource |
| 215 | cdm_demo_gold.Dim4LearningResourceContactPhoneNumbers |  | 12 | LearningResource |
| 216 | cdm_demo_gold.Dim4LearningResourceContactEmails |  | 12 | LearningResource |
| 217 | cdm_demo_gold.Dim4LearningResourceSubjectAreaOtherCodeList |  | 12 | LearningResource |
| 218 | cdm_demo_gold.Dim4LearningResourceComponentTeachingLearningStrategies |  | 12 | LearningResource |
| 219 | cdm_demo_gold.Dim4LearningResourceComponentAssociatedObjects |  | 12 | LearningResource |
| 98 | cdm_demo_gold.Dim1EquipmentInfo |  | 13 | EquipmentInfo |
| 191 | cdm_demo_gold.Dim3RoomInfo |  | 14 | RoomInfo |
| 223 | cdm_demo_gold.Dim4RoomInfoStaffList |  | 14 | RoomInfo |
| 224 | cdm_demo_gold.Dim4ResourceList |  | 15 | ResourceList |
| 190 | cdm_demo_gold.Dim3LibraryPatronStatus |  | 16 | LibraryPatronStatus |
| 220 | cdm_demo_gold.Dim4LibraryPatronElectronicIdList |  | 16 | LibraryPatronStatus |
| 221 | cdm_demo_gold.Dim4LibraryPatronTransactionList |  | 16 | LibraryPatronStatus |
| 222 | cdm_demo_gold.Dim4LibraryPatronMessageList |  | 16 | LibraryPatronStatus |
| 230 | cdm_demo_gold.Dim5LibraryItemElectronicIdList |  | 16 | LibraryPatronStatus |
| 189 | cdm_demo_gold.Dim3TermInfo |  | 17 | TermInfo |
| 226 | cdm_demo_gold.Dim4SchoolCourseInfo |  | 18 | SchoolCourseInfo |
| 232 | cdm_demo_gold.Dim5SchoolCourseSubjectAreaList |  | 18 | SchoolCourseInfo |
| 239 | cdm_demo_gold.Dim6SchoolCourseSubjectAreaOtherCodes |  | 18 | SchoolCourseInfo |
| 235 | cdm_demo_gold.Dim5SectionInfo |  | 19 | SectionInfo |
| 242 | cdm_demo_gold.Dim6SectionInfoOtherCodes |  | 19 | SectionInfo |
| 243 | cdm_demo_gold.Fact6StudentSectionEnrollment |  | 20 | StudentSectionEnrollment |
| 192 | cdm_demo_gold.Dim3TimeTable |  | 21 | TimeTable |
| 225 | cdm_demo_gold.Dim4TimeTableDay |  | 21 | TimeTable |
| 231 | cdm_demo_gold.Dim5TimeTablePeriod |  | 21 | TimeTable |
| 233 | cdm_demo_gold.Dim5TimeTableSubject |  | 22 | TimeTableSubject |
| 240 | cdm_demo_gold.Dim6TimeTableSubjectOtherCodes |  | 22 | TimeTableSubject |
| 241 | cdm_demo_gold.Dim6TeachingGroup |  | 23 | TeachingGroup |
| 244 | cdm_demo_gold.Dim7TeachingGroupStudentList |  | 23 | TeachingGroup |
| 245 | cdm_demo_gold.Dim7TeachingGroupTeacherList |  | 23 | TeachingGroup |
| 248 | cdm_demo_gold.Dim8TeachingGroupPeriodList |  | 23 | TeachingGroup |
| 246 | cdm_demo_gold.Dim7TimeTableCell |  | 24 | TimeTableCell |
| 249 | cdm_demo_gold.Dim8TimeTableCellTeacherCoverList |  | 24 | TimeTableCell |
| 250 | cdm_demo_gold.Dim8TimeTableCellRoomList |  | 24 | TimeTableCell |
| 99 | cdm_demo_gold.Dim1TimeTableContainer |  | 25 | TimeTableContainer |
| 227 | cdm_demo_gold.Dim4TimeTableContainerSchedule |  | 25 | TimeTableContainer |
| 234 | cdm_demo_gold.Dim5TimeTableContainerDay |  | 25 | TimeTableContainer |
| 247 | cdm_demo_gold.Dim7TimeTableContainerTeachingGroupScheduleList |  | 25 | TimeTableContainer |
| 251 | cdm_demo_gold.Dim8TimeTableContainerScheduleCellList |  | 25 | TimeTableContainer |
| 252 | cdm_demo_gold.Dim8TimeTableContainerTeachingGroupPeriodList |  | 25 | TimeTableContainer |
| 253 | cdm_demo_gold.Dim8TimeTableContainerTeachingGroupStudentList |  | 25 | TimeTableContainer |
| 254 | cdm_demo_gold.Dim8TimeTableContainerTeachingGroupTeacherList |  | 25 | TimeTableContainer |
| 256 | cdm_demo_gold.Dim9TimeTableContainerTeacherCoverList |  | 25 | TimeTableContainer |
| 257 | cdm_demo_gold.Dim9TimeTableContainerRoomList |  | 25 | TimeTableContainer |
| 255 | cdm_demo_gold.Dim8ScheduledActivity |  | 26 | ScheduledActivity |
| 258 | cdm_demo_gold.Dim9ScheduledActivityTeacherCoverList |  | 26 | ScheduledActivity |
| 259 | cdm_demo_gold.Dim9ScheduledActivityRoomList |  | 26 | ScheduledActivity |
| 260 | cdm_demo_gold.Dim9ScheduledActivityAddressList |  | 26 | ScheduledActivity |
| 261 | cdm_demo_gold.Dim9ScheduledActivityStudentList |  | 26 | ScheduledActivity |
| 262 | cdm_demo_gold.Dim9ScheduledActivityTeachingGroupList |  | 26 | ScheduledActivity |
| 263 | cdm_demo_gold.Dim9ScheduledActivityYearLevels |  | 26 | ScheduledActivity |
| 264 | cdm_demo_gold.Dim9ScheduledActivityChangeReasonList |  | 26 | ScheduledActivity |
| 265 | cdm_demo_gold.Fact9ResourceBooking |  | 27 | ResourceBooking |
