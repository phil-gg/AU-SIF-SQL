# Explanation of Select Only folder and files

SQL scripts here have filenames that each align with one table from **"Drop-then-Create-SIF-tables.sql"**.
They select the data for the target table only, without inserting them into any target SIF tables.

The "tables list" files track all the scripts to be built, and *(with "xxx.yyy" filename prefix)* recommends the order in which  to complete the mappings, and documents the dependency order in which data insert must occur.
The status table below is a copy-paste of "tables list" columns A to E into [tablesgenerator.com/markdown_tables](https://www.tablesgenerator.com/markdown_tables).

## Current state of mapping

| Create Table Order | TableName | Mapped Yet? | Group | Area |
|-------------------:|:----------|:-----------:|------:|:-----|
| 1 | Dim0StaffEmploymentStatus | ✅ | 0 | Tables populated by SIF specification |
| 2 | Dim0ElectronicIdType | ✅ | 0 | Tables populated by SIF specification |
| 3 | Dim0NameUsageType | ✅ | 0 | Tables populated by SIF specification |
| 4 | Dim0YesNoType | ✅ | 0 | Tables populated by SIF specification |
| 5 | Dim0IndigenousStatus | ✅ | 0 | Tables populated by SIF specification |
| 6 | Dim0SexCode | ✅ | 0 | Tables populated by SIF specification |
| 7 | Dim0BirthdateVerification | ✅ | 0 | Tables populated by SIF specification |
| 8 | Dim0StateTerritoryCode | ✅ | 0 | Tables populated by SIF specification |
| 9 | Dim0AustralianCitizenshipStatus | ✅ | 0 | Tables populated by SIF specification |
| 10 | Dim0EnglishProficiency | ✅ | 0 | Tables populated by SIF specification |
| 11 | Dim0DwellingArrangement | ✅ | 0 | Tables populated by SIF specification |
| 12 | Dim0ReligionType | ✅ | 0 | Tables populated by SIF specification |
| 13 | Dim0PermanentResidentStatus | ✅ | 0 | Tables populated by SIF specification |
| 14 | Dim0VisaStudyEntitlement | ✅ | 0 | Tables populated by SIF specification |
| 15 | Dim0ImmunisationCertificateStatus | ✅ | 0 | Tables populated by SIF specification |
| 16 | Dim0CulturalEthnicGroups | ✅ | 0 | Tables populated by SIF specification |
| 17 | Dim0MaritalStatus | ✅ | 0 | Tables populated by SIF specification |
| 18 | Dim0AddressType | ✅ | 0 | Tables populated by SIF specification |
| 19 | Dim0AddressRole | ✅ | 0 | Tables populated by SIF specification |
| 20 | Dim0SpatialUnitType | ✅ | 0 | Tables populated by SIF specification |
| 21 | Dim0PhoneNumberType | ✅ | 0 | Tables populated by SIF specification |
| 22 | Dim0EmailType | ✅ | 0 | Tables populated by SIF specification |
| 23 | Dim0AlertMessageType | ✅ | 0 | Tables populated by SIF specification |
| 24 | Dim0MedicalSeverity | ✅ | 0 | Tables populated by SIF specification |
| 25 | Dim0DisabilityNCCDCategory | ✅ | 0 | Tables populated by SIF specification |
| 26 | Dim0PrePrimaryEducationHours | ✅ | 0 | Tables populated by SIF specification |
| 27 | Dim0SchoolEnrollmentType | ✅ | 0 | Tables populated by SIF specification |
| 28 | Dim0FFPOSStatusCode | ✅ | 0 | Tables populated by SIF specification |
| 29 | Dim0DisabilityLevelOfAdjustment | ✅ | 0 | Tables populated by SIF specification |
| 30 | Dim0BoardingStatus | ✅ | 0 | Tables populated by SIF specification |
| 31 | Dim0EmploymentType | ✅ | 0 | Tables populated by SIF specification |
| 32 | Dim0SchoolEducationLevelType | ✅ | 0 | Tables populated by SIF specification |
| 33 | Dim0NonSchoolEducationType | ✅ | 0 | Tables populated by SIF specification |
| 34 | Dim0EducationAgencyType | ✅ | 0 | Tables populated by SIF specification |
| 35 | Dim0OperationalStatus | ✅ | 0 | Tables populated by SIF specification |
| 36 | Dim0SchoolLevelType | ✅ | 0 | Tables populated by SIF specification |
| 37 | Dim0SchoolFocusCode | ✅ | 0 | Tables populated by SIF specification |
| 38 | Dim0ARIAClass | ✅ | 0 | Tables populated by SIF specification |
| 39 | Dim0SessionType | ✅ | 0 | Tables populated by SIF specification |
| 40 | Dim0YearLevelCode | ✅ | 0 | Tables populated by SIF specification |
| 41 | Dim0FederalElectorateList | ✅ | 0 | Tables populated by SIF specification |
| 42 | Dim0SchoolSectorCode | ✅ | 0 | Tables populated by SIF specification |
| 43 | Dim0SystemicStatus | ✅ | 0 | Tables populated by SIF specification |
| 44 | Dim0SchoolSystemType | ✅ | 0 | Tables populated by SIF specification |
| 45 | Dim0SchoolGeographicLocationType | ✅ | 0 | Tables populated by SIF specification |
| 46 | Dim0SchoolCoEdStatus | ✅ | 0 | Tables populated by SIF specification |
| 47 | Dim0AusTimeZoneList | ✅ | 0 | Tables populated by SIF specification |
| 48 | Dim0PartyType | ✅ | 0 | Tables populated by SIF specification |
| 49 | Dim0AuthenticationSource | ✅ | 0 | Tables populated by SIF specification |
| 50 | Dim0EncryptionAlgorithm | ✅ | 0 | Tables populated by SIF specification |
| 51 | Dim0PermissionCategoryCode | ✅ | 0 | Tables populated by SIF specification |
| 52 | Dim0PermissionYesNoType | ✅ | 0 | Tables populated by SIF specification |
| 53 | Dim0StaffActivity | ✅ | 0 | Tables populated by SIF specification |
| 54 | Dim0RelationshipToStudentType | ✅ | 0 | Tables populated by SIF specification |
| 55 | Dim0ParentRelationshipStatus | ✅ | 0 | Tables populated by SIF specification |
| 56 | Dim0ContactSourceType | ✅ | 0 | Tables populated by SIF specification |
| 57 | Dim0ContactMethod | ✅ | 0 | Tables populated by SIF specification |
| 58 | Dim0CodesetForOtherCodeListType | ✅ | 0 | Tables populated by SIF specification |
| 59 | Dim0EnrollmentTimeFrame | ✅ | 0 | Tables populated by SIF specification |
| 60 | Dim0EnrollmentEntryType | ✅ | 0 | Tables populated by SIF specification |
| 61 | Dim0EnrollmentExitWithdrawalType | ✅ | 0 | Tables populated by SIF specification |
| 62 | Dim0EnrollmentExitWithdrawalStatus | ✅ | 0 | Tables populated by SIF specification |
| 63 | Dim0StudentSchoolEnrollmentOtherCodeField | ✅ | 0 | Tables populated by SIF specification |
| 64 | Dim0FullTimePartTimeStatusCode | ✅ | 0 | Tables populated by SIF specification |
| 65 | Dim0PublicSchoolCatchmentStatus | ✅ | 0 | Tables populated by SIF specification |
| 66 | Dim0StudentSchoolEnrollmentRecordClosureReason | ✅ | 0 | Tables populated by SIF specification |
| 67 | Dim0StudentSchoolEnrollmentPromotionStatus | ✅ | 0 | Tables populated by SIF specification |
| 68 | Dim0TravelMode | ✅ | 0 | Tables populated by SIF specification |
| 69 | Dim0TravelAccompaniment | ✅ | 0 | Tables populated by SIF specification |
| 70 | Dim0StudentGroupCategoryCode | ✅ | 0 | Tables populated by SIF specification |
| 71 | Dim0AbstractContentType | ✅ | 0 | Tables populated by SIF specification |
| 72 | Dim0AustralianCurriculumStrand | ✅ | 0 | Tables populated by SIF specification |
| 73 | Dim0TermInfoSessionType | ✅ | 0 | Tables populated by SIF specification |
| 74 | Dim0EquipmentType | ✅ | 0 | Tables populated by SIF specification |
| 75 | Dim0OwnerOrLocationSIF_RefObject | ✅ | 0 | Tables populated by SIF specification |
| 76 | Dim0ResourceType | ✅ | 0 | Tables populated by SIF specification |
| 77 | Dim0YesNoOnly | ✅ | 0 | Tables populated by SIF specification |
| 78 | Dim0AcademicYearEntryType | ✅ | 0 | Tables populated by SIF specification |
| 79 | Dim0TeacherCoverCredit | ✅ | 0 | Tables populated by SIF specification |
| 80 | Dim0TeacherCoverSupervision | ✅ | 0 | Tables populated by SIF specification |
| 81 | Dim0ScheduledActivityType | ✅ | 0 | Tables populated by SIF specification |
| 82 | Dim0TimeTableChangeType | ✅ | 0 | Tables populated by SIF specification |
| 83 | Dim0MediumOfInstruction | ✅ | 0 | Tables populated by SIF specification |
| 84 | Dim0LanguageOfInstruction | ✅ | 0 | Tables populated by SIF specification |
| 85 | Dim0ReceivingLocationOfInstruction | ✅ | 0 | Tables populated by SIF specification |
| 86 | Dim0SectionInfoOtherCodeField | ✅ | 0 | Tables populated by SIF specification |
| 87 | Dim1Country | ✅ | 1 | eMinerva sourced reference data |
| 88 | Dim1Languages | ✅ | 1 | eMinerva sourced reference data |
| 89 | Dim1VisaSubClass | ✅ | 1 | eMinerva sourced reference data |
| 90 | Dim1StaffPersonal | ✅ | 2 | StaffPersonal |
| 91 | Dim1StaffHouseholdContactInfo |  | 2 | StaffPersonal |
| 100 | Dim2StaffList |  | 2 | StaffPersonal |
| 101 | Dim2StaffElectronicIdList |  | 2 | StaffPersonal |
| 102 | Dim2StaffOtherIdList |  | 2 | StaffPersonal |
| 103 | Dim2StaffNames | ✅ | 2 | StaffPersonal |
| 104 | Dim2StaffDemographics |  | 2 | StaffPersonal |
| 105 | Bridge2StaffCountriesOfCitizenship |  | 2 | StaffPersonal |
| 106 | Bridge2StaffCountriesOfResidency |  | 2 | StaffPersonal |
| 107 | Bridge2StaffLanguages |  | 2 | StaffPersonal |
| 108 | Dim2StaffReligiousEvent |  | 2 | StaffPersonal |
| 109 | Dim2StaffPassport |  | 2 | StaffPersonal |
| 110 | Dim2StaffAddressList |  | 2 | StaffPersonal |
| 111 | Dim2StaffPhoneNumberList |  | 2 | StaffPersonal |
| 112 | Dim2StaffEmailList |  | 2 | StaffPersonal |
| 113 | Bridge2StaffHouseholdContactInfo |  | 2 | StaffPersonal |
| 114 | Dim2StaffHouseholdContactAddressList |  | 2 | StaffPersonal |
| 115 | Dim2StaffHouseholdContactPhoneNumberList |  | 2 | StaffPersonal |
| 116 | Dim2StaffHouseholdContactEmailList |  | 2 | StaffPersonal |
| 117 | Dim2StaffMostRecentNAPLANClassList |  | 2 | StaffPersonal |
| 193 | Dim4StaffPersonalMostRecent |  | 2 | StaffPersonal |
| 96 | Dim1LEAInfo | ✅ | 3 | LEAInfo |
| 153 | Dim2LEAAddressList |  | 3 | LEAInfo |
| 154 | Dim2LEAPhoneNumberList |  | 3 | LEAInfo |
| 155 | Dim2LEAContactInfo |  | 3 | LEAInfo |
| 159 | Dim3LEAContactAddressList |  | 3 | LEAInfo |
| 160 | Dim3LEAContactPhoneNumberList |  | 3 | LEAInfo |
| 161 | Dim3LEAContactEmailList |  | 3 | LEAInfo |
| 156 | Dim2SchoolInfo | ✅ | 4 | SchoolInfo |
| 162 | Dim3SchoolACARAIdList |  | 4 | SchoolInfo |
| 163 | Dim3SchoolOtherIdList |  | 4 | SchoolInfo |
| 164 | Dim3SchoolFocus |  | 4 | SchoolInfo |
| 165 | Dim3SchoolAddressList |  | 4 | SchoolInfo |
| 166 | Dim3SchoolPhoneNumberList |  | 4 | SchoolInfo |
| 167 | Dim3SchoolEmailList |  | 4 | SchoolInfo |
| 168 | Dim3SchoolPrincipalPhoneNumberList |  | 4 | SchoolInfo |
| 169 | Dim3SchoolPrincipalEmailList |  | 4 | SchoolInfo |
| 170 | Dim3SchoolContactInfo |  | 4 | SchoolInfo |
| 171 | Dim3SchoolCampus |  | 4 | SchoolInfo |
| 172 | Dim3SchoolGroup |  | 4 | SchoolInfo |
| 173 | Dim3SchoolYearLevels |  | 4 | SchoolInfo |
| 174 | Dim3SchoolEnrollmentByYearLevel |  | 4 | SchoolInfo |
| 195 | Dim4SchoolContactAddressList |  | 4 | SchoolInfo |
| 196 | Dim4SchoolContactPhoneNumberList |  | 4 | SchoolInfo |
| 197 | Dim4SchoolContactEmailList |  | 4 | SchoolInfo |
| 92 | Dim1StudentPersonal | ✅ | 5 | StudentPersonal |
| 93 | Dim1StudentHouseholdContactInfo |  | 5 | StudentPersonal |
| 118 | Dim2StudentList |  | 5 | StudentPersonal |
| 119 | Dim2StudentAlertMessages |  | 5 | StudentPersonal |
| 120 | Dim2StudentMedicalAlertMessages |  | 5 | StudentPersonal |
| 121 | Dim2StudentElectronicIdList |  | 5 | StudentPersonal |
| 122 | Dim2StudentOtherIdList |  | 5 | StudentPersonal |
| 123 | Dim2StudentNames |  | 5 | StudentPersonal |
| 124 | Dim2StudentDemographics |  | 5 | StudentPersonal |
| 125 | Bridge2StudentCountriesOfCitizenship |  | 5 | StudentPersonal |
| 126 | Bridge2StudentCountriesOfResidency |  | 5 | StudentPersonal |
| 127 | Bridge2StudentLanguages |  | 5 | StudentPersonal |
| 128 | Dim2StudentReligiousEvent |  | 5 | StudentPersonal |
| 129 | Dim2StudentPassport |  | 5 | StudentPersonal |
| 130 | Dim2StudentAddressList |  | 5 | StudentPersonal |
| 131 | Dim2StudentPhoneNumberList |  | 5 | StudentPersonal |
| 132 | Dim2StudentEmailList |  | 5 | StudentPersonal |
| 133 | Bridge2StudentHouseholdContactInfo |  | 5 | StudentPersonal |
| 134 | Dim2StudentHouseholdContactAddressList |  | 5 | StudentPersonal |
| 135 | Dim2StudentHouseholdContactPhoneNumberList |  | 5 | StudentPersonal |
| 136 | Dim2StudentHouseholdContactEmailList |  | 5 | StudentPersonal |
| 194 | Dim4StudentPersonalMostRecent |  | 5 | StudentPersonal |
| 180 | Fact3StudentSchoolEnrollment | ✅ | 6 | StudentSchoolEnrollment |
| 210 | Fact4StudentSchoolEnrollmentOtherCodes |  | 6 | StudentSchoolEnrollment |
| 211 | Fact4StudentSchoolEnrollmentStudentGroup |  | 6 | StudentSchoolEnrollment |
| 212 | Fact4StudentSchoolEnrollmentPublishingPermissions |  | 6 | StudentSchoolEnrollment |
| 237 | Fact6StudentSubjectChoice |  | 6 | StudentSchoolEnrollment |
| 238 | Fact6StudentSubjectChoiceOtherCode |  | 6 | StudentSchoolEnrollment |
| 178 | Fact3StaffAssignment |  | 7 | StaffAssignment |
| 205 | Fact4StaffAssignmentActivityExtension |  | 7 | StaffAssignment |
| 206 | Fact4StaffAssignmentActivityExtensionOtherCode |  | 7 | StaffAssignment |
| 207 | Fact4StaffAssignmentYearLevels |  | 7 | StaffAssignment |
| 208 | Fact4StaffAssignmentCalendarSummaryList |  | 7 | StaffAssignment |
| 236 | Fact6StaffAssignmentSubjectList |  | 7 | StaffAssignment |
| 94 | Dim1StudentContactPersonal |  | 8 | StudentContactPersonal |
| 95 | Dim1StudentContactHouseholdContactInfo |  | 8 | StudentContactPersonal |
| 137 | Dim2StudentContactPersonList |  | 8 | StudentContactPersonal |
| 138 | Dim2StudentContactOtherIdList |  | 8 | StudentContactPersonal |
| 139 | Dim2StudentContactNames |  | 8 | StudentContactPersonal |
| 140 | Dim2StudentContactDemographics |  | 8 | StudentContactPersonal |
| 141 | Bridge2StudentContactCountriesOfCitizenship |  | 8 | StudentContactPersonal |
| 142 | Bridge2StudentContactCountriesOfResidency |  | 8 | StudentContactPersonal |
| 143 | Bridge2StudentContactLanguages |  | 8 | StudentContactPersonal |
| 144 | Dim2StudentContactReligiousEvent |  | 8 | StudentContactPersonal |
| 145 | Dim2StudentContactPassport |  | 8 | StudentContactPersonal |
| 146 | Dim2StudentContactAddressList |  | 8 | StudentContactPersonal |
| 147 | Dim2StudentContactPhoneNumberList |  | 8 | StudentContactPersonal |
| 148 | Dim2StudentContactEmailList |  | 8 | StudentContactPersonal |
| 149 | Bridge2StudentContactHouseholdContactInfo |  | 8 | StudentContactPersonal |
| 150 | Dim2StudentContactHouseholdContactAddressList |  | 8 | StudentContactPersonal |
| 151 | Dim2StudentContactHouseholdContactPhoneNumberList |  | 8 | StudentContactPersonal |
| 152 | Dim2StudentContactHouseholdContactEmailList |  | 8 | StudentContactPersonal |
| 179 | Fact3StudentContactRelationship |  | 9 | StudentContactRelationship |
| 209 | Fact4StudentContactRelationshipHouseholdList |  | 9 | StudentContactRelationship |
| 157 | Dim2PartyList |  | 10 | Party, Identity, PersonPicture & PrivacyObligation(s) |
| 175 | Dim3Identity |  | 10 | Party, Identity, PersonPicture & PrivacyObligation(s) |
| 176 | Dim3PersonPicture |  | 10 | Party, Identity, PersonPicture & PrivacyObligation(s) |
| 177 | Dim3PersonPrivacyObligationDocument |  | 10 | Party, Identity, PersonPicture & PrivacyObligation(s) |
| 198 | Dim4IdentityAssertions |  | 10 | Party, Identity, PersonPicture & PrivacyObligation(s) |
| 199 | Dim4IdentityPasswordList |  | 10 | Party, Identity, PersonPicture & PrivacyObligation(s) |
| 200 | Dim4PersonPicturePublishingPermissions |  | 10 | Party, Identity, PersonPicture & PrivacyObligation(s) |
| 201 | Dim4PersonPrivacySettingLocation |  | 10 | Party, Identity, PersonPicture & PrivacyObligation(s) |
| 202 | Dim4PersonPrivacyDataDomain |  | 10 | Party, Identity, PersonPicture & PrivacyObligation(s) |
| 203 | Dim4PersonPrivacyPermissionToParticipate |  | 10 | Party, Identity, PersonPicture & PrivacyObligation(s) |
| 204 | Dim4PersonPrivacyApplicableLaw |  | 10 | Party, Identity, PersonPicture & PrivacyObligation(s) |
| 228 | Dim5PersonPrivacyDataDomainShareWith |  | 10 | Party, Identity, PersonPicture & PrivacyObligation(s) |
| 229 | Dim5PersonPrivacyDataDomainDoNotShareWith |  | 10 | Party, Identity, PersonPicture & PrivacyObligation(s) |
| 97 | Dim1LearningResourcePackage |  | 11 | LearningResourcePackage |
| 158 | Dim2LearningResource |  | 12 | LearningResource |
| 181 | Dim3LearningResourceContacts |  | 12 | LearningResource |
| 182 | Dim3LearningResourceYearLevels |  | 12 | LearningResource |
| 183 | Dim3LearningResourceAustralianCurriculumStrandList |  | 12 | LearningResource |
| 184 | Dim3LearningResourceSubjectAreaList |  | 12 | LearningResource |
| 185 | Dim3LearningResourceMediaTypes |  | 12 | LearningResource |
| 186 | Dim3LearningResourceApprovals |  | 12 | LearningResource |
| 187 | Dim3LearningResourceEvaluations |  | 12 | LearningResource |
| 188 | Dim3LearningResourceComponents |  | 12 | LearningResource |
| 213 | Dim4LearningResourceContactNames |  | 12 | LearningResource |
| 214 | Dim4LearningResourceContactAddresses |  | 12 | LearningResource |
| 215 | Dim4LearningResourceContactPhoneNumbers |  | 12 | LearningResource |
| 216 | Dim4LearningResourceContactEmails |  | 12 | LearningResource |
| 217 | Dim4LearningResourceSubjectAreaOtherCodeList |  | 12 | LearningResource |
| 218 | Dim4LearningResourceComponentTeachingLearningStrategies |  | 12 | LearningResource |
| 219 | Dim4LearningResourceComponentAssociatedObjects |  | 12 | LearningResource |
| 98 | Dim1EquipmentInfo |  | 13 | EquipmentInfo |
| 191 | Dim3RoomInfo |  | 14 | RoomInfo |
| 223 | Dim4RoomInfoStaffList |  | 14 | RoomInfo |
| 224 | Dim4ResourceList |  | 15 | ResourceList |
| 190 | Dim3LibraryPatronStatus |  | 16 | LibraryPatronStatus |
| 220 | Dim4LibraryPatronElectronicIdList |  | 16 | LibraryPatronStatus |
| 221 | Dim4LibraryPatronTransactionList |  | 16 | LibraryPatronStatus |
| 222 | Dim4LibraryPatronMessageList |  | 16 | LibraryPatronStatus |
| 230 | Dim5LibraryItemElectronicIdList |  | 16 | LibraryPatronStatus |
| 189 | Dim3TermInfo |  | 17 | TermInfo |
| 226 | Dim4SchoolCourseInfo |  | 18 | SchoolCourseInfo |
| 232 | Dim5SchoolCourseSubjectAreaList |  | 18 | SchoolCourseInfo |
| 239 | Dim6SchoolCourseSubjectAreaOtherCodes |  | 18 | SchoolCourseInfo |
| 235 | Dim5SectionInfo |  | 19 | SectionInfo |
| 242 | Dim6SectionInfoOtherCodes |  | 19 | SectionInfo |
| 243 | Fact6StudentSectionEnrollment |  | 20 | StudentSectionEnrollment |
| 192 | Dim3TimeTable |  | 21 | TimeTable |
| 225 | Dim4TimeTableDay |  | 21 | TimeTable |
| 231 | Dim5TimeTablePeriod |  | 21 | TimeTable |
| 233 | Dim5TimeTableSubject |  | 22 | TimeTableSubject |
| 240 | Dim6TimeTableSubjectOtherCodes |  | 22 | TimeTableSubject |
| 241 | Dim6TeachingGroup |  | 23 | TeachingGroup |
| 244 | Dim7TeachingGroupStudentList |  | 23 | TeachingGroup |
| 245 | Dim7TeachingGroupTeacherList |  | 23 | TeachingGroup |
| 248 | Dim8TeachingGroupPeriodList |  | 23 | TeachingGroup |
| 246 | Dim7TimeTableCell |  | 24 | TimeTableCell |
| 249 | Dim8TimeTableCellTeacherCoverList |  | 24 | TimeTableCell |
| 250 | Dim8TimeTableCellRoomList |  | 24 | TimeTableCell |
| 99 | Dim1TimeTableContainer |  | 25 | TimeTableContainer |
| 227 | Dim4TimeTableContainerSchedule |  | 25 | TimeTableContainer |
| 234 | Dim5TimeTableContainerDay |  | 25 | TimeTableContainer |
| 247 | Dim7TimeTableContainerTeachingGroupScheduleList |  | 25 | TimeTableContainer |
| 251 | Dim8TimeTableContainerScheduleCellList |  | 25 | TimeTableContainer |
| 252 | Dim8TimeTableContainerTeachingGroupPeriodList |  | 25 | TimeTableContainer |
| 253 | Dim8TimeTableContainerTeachingGroupStudentList |  | 25 | TimeTableContainer |
| 254 | Dim8TimeTableContainerTeachingGroupTeacherList |  | 25 | TimeTableContainer |
| 256 | Dim9TimeTableContainerTeacherCoverList |  | 25 | TimeTableContainer |
| 257 | Dim9TimeTableContainerRoomList |  | 25 | TimeTableContainer |
| 255 | Dim8ScheduledActivity |  | 26 | ScheduledActivity |
| 258 | Dim9ScheduledActivityTeacherCoverList |  | 26 | ScheduledActivity |
| 259 | Dim9ScheduledActivityRoomList |  | 26 | ScheduledActivity |
| 260 | Dim9ScheduledActivityAddressList |  | 26 | ScheduledActivity |
| 261 | Dim9ScheduledActivityStudentList |  | 26 | ScheduledActivity |
| 262 | Dim9ScheduledActivityTeachingGroupList |  | 26 | ScheduledActivity |
| 263 | Dim9ScheduledActivityYearLevels |  | 26 | ScheduledActivity |
| 264 | Dim9ScheduledActivityChangeReasonList |  | 26 | ScheduledActivity |
| 265 | Fact9ResourceBooking |  | 27 | ResourceBooking |
