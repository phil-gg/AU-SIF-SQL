-- Phase 1 & 2 target data model build complete:
--  86 pre-populated Dim0 tables
-- 179 target tables to (potentially) populate
-- 265 tables in total

-- Tables populated by SIF specification:

SELECT * FROM cdm_demo_gold.Dim0StaffEmploymentStatus;
SELECT * FROM cdm_demo_gold.Dim0ElectronicIdType;
SELECT * FROM cdm_demo_gold.Dim0NameUsageType;
SELECT * FROM cdm_demo_gold.Dim0YesNoType;
SELECT * FROM cdm_demo_gold.Dim0IndigenousStatus;
SELECT * FROM cdm_demo_gold.Dim0SexCode;
SELECT * FROM cdm_demo_gold.Dim0BirthdateVerification;
SELECT * FROM cdm_demo_gold.Dim0StateTerritoryCode;
SELECT * FROM cdm_demo_gold.Dim0AustralianCitizenshipStatus;
SELECT * FROM cdm_demo_gold.Dim0EnglishProficiency;
SELECT * FROM cdm_demo_gold.Dim0DwellingArrangement;
SELECT * FROM cdm_demo_gold.Dim0ReligionType;
SELECT * FROM cdm_demo_gold.Dim0PermanentResidentStatus;
SELECT * FROM cdm_demo_gold.Dim0VisaStudyEntitlement;
SELECT * FROM cdm_demo_gold.Dim0ImmunisationCertificateStatus;
SELECT * FROM cdm_demo_gold.Dim0CulturalEthnicGroups;
SELECT * FROM cdm_demo_gold.Dim0MaritalStatus;
SELECT * FROM cdm_demo_gold.Dim0AddressType;
SELECT * FROM cdm_demo_gold.Dim0AddressRole;
SELECT * FROM cdm_demo_gold.Dim0SpatialUnitType;
SELECT * FROM cdm_demo_gold.Dim0PhoneNumberType;
SELECT * FROM cdm_demo_gold.Dim0EmailType;
SELECT * FROM cdm_demo_gold.Dim0AlertMessageType;
SELECT * FROM cdm_demo_gold.Dim0MedicalSeverity;
SELECT * FROM cdm_demo_gold.Dim0DisabilityNCCDCategory;
SELECT * FROM cdm_demo_gold.Dim0PrePrimaryEducationHours;
SELECT * FROM cdm_demo_gold.Dim0SchoolEnrollmentType;
SELECT * FROM cdm_demo_gold.Dim0FFPOSStatusCode;
SELECT * FROM cdm_demo_gold.Dim0DisabilityLevelOfAdjustment;
SELECT * FROM cdm_demo_gold.Dim0BoardingStatus;
SELECT * FROM cdm_demo_gold.Dim0EmploymentType;
SELECT * FROM cdm_demo_gold.Dim0SchoolEducationLevelType;
SELECT * FROM cdm_demo_gold.Dim0NonSchoolEducationType;
SELECT * FROM cdm_demo_gold.Dim0EducationAgencyType;
SELECT * FROM cdm_demo_gold.Dim0OperationalStatus;
SELECT * FROM cdm_demo_gold.Dim0SchoolLevelType;
SELECT * FROM cdm_demo_gold.Dim0SchoolFocusCode;
SELECT * FROM cdm_demo_gold.Dim0ARIAClass;
SELECT * FROM cdm_demo_gold.Dim0SessionType;
SELECT * FROM cdm_demo_gold.Dim0YearLevelCode;
SELECT * FROM cdm_demo_gold.Dim0FederalElectorateList;
SELECT * FROM cdm_demo_gold.Dim0SchoolSectorCode;
SELECT * FROM cdm_demo_gold.Dim0SystemicStatus;
SELECT * FROM cdm_demo_gold.Dim0SchoolSystemType;
SELECT * FROM cdm_demo_gold.Dim0SchoolGeographicLocationType;
SELECT * FROM cdm_demo_gold.Dim0SchoolCoEdStatus;
SELECT * FROM cdm_demo_gold.Dim0AusTimeZoneList;
SELECT * FROM cdm_demo_gold.Dim0PartyType;
SELECT * FROM cdm_demo_gold.Dim0AuthenticationSource;
SELECT * FROM cdm_demo_gold.Dim0EncryptionAlgorithm;
SELECT * FROM cdm_demo_gold.Dim0PermissionCategoryCode;
SELECT * FROM cdm_demo_gold.Dim0PermissionYesNoType;
SELECT * FROM cdm_demo_gold.Dim0StaffActivity;
SELECT * FROM cdm_demo_gold.Dim0RelationshipToStudentType;
SELECT * FROM cdm_demo_gold.Dim0ParentRelationshipStatus;
SELECT * FROM cdm_demo_gold.Dim0ContactSourceType;
SELECT * FROM cdm_demo_gold.Dim0ContactMethod;
SELECT * FROM cdm_demo_gold.Dim0CodesetForOtherCodeListType;
SELECT * FROM cdm_demo_gold.Dim0EnrollmentTimeFrame;
SELECT * FROM cdm_demo_gold.Dim0EnrollmentEntryType;
SELECT * FROM cdm_demo_gold.Dim0EnrollmentExitWithdrawalType;
SELECT * FROM cdm_demo_gold.Dim0EnrollmentExitWithdrawalStatus;
SELECT * FROM cdm_demo_gold.Dim0StudentSchoolEnrollmentOtherCodeField;
SELECT * FROM cdm_demo_gold.Dim0FullTimePartTimeStatusCode;
SELECT * FROM cdm_demo_gold.Dim0PublicSchoolCatchmentStatus;
SELECT * FROM cdm_demo_gold.Dim0StudentSchoolEnrollmentRecordClosureReason;
SELECT * FROM cdm_demo_gold.Dim0StudentSchoolEnrollmentPromotionStatus;
SELECT * FROM cdm_demo_gold.Dim0TravelMode;
SELECT * FROM cdm_demo_gold.Dim0TravelAccompaniment;
SELECT * FROM cdm_demo_gold.Dim0StudentGroupCategoryCode;
SELECT * FROM cdm_demo_gold.Dim0AbstractContentType;
SELECT * FROM cdm_demo_gold.Dim0AustralianCurriculumStrand;
SELECT * FROM cdm_demo_gold.Dim0TermInfoSessionType;
SELECT * FROM cdm_demo_gold.Dim0EquipmentType;
SELECT * FROM cdm_demo_gold.Dim0OwnerOrLocationSIF_RefObject;
SELECT * FROM cdm_demo_gold.Dim0ResourceType;
SELECT * FROM cdm_demo_gold.Dim0YesNoOnly;
SELECT * FROM cdm_demo_gold.Dim0AcademicYearEntryType;
SELECT * FROM cdm_demo_gold.Dim0TeacherCoverCredit;
SELECT * FROM cdm_demo_gold.Dim0TeacherCoverSupervision;
SELECT * FROM cdm_demo_gold.Dim0ScheduledActivityType;
SELECT * FROM cdm_demo_gold.Dim0TimeTableChangeType;
SELECT * FROM cdm_demo_gold.Dim0MediumOfInstruction;
SELECT * FROM cdm_demo_gold.Dim0LanguageOfInstruction;
SELECT * FROM cdm_demo_gold.Dim0ReceivingLocationOfInstruction;
SELECT * FROM cdm_demo_gold.Dim0SectionInfoOtherCodeField;

-- eMinerva sourced reference data:

SELECT * FROM cdm_demo_gold.Dim1Country;
SELECT * FROM cdm_demo_gold.Dim1Languages;
SELECT * FROM cdm_demo_gold.Dim1VisaSubClass;

-- StaffPersonal tables:

SELECT * FROM cdm_demo_gold.Dim1StaffPersonal;
SELECT * FROM cdm_demo_gold.Dim1StaffHouseholdContactInfo;
SELECT * FROM cdm_demo_gold.Dim2StaffList;
SELECT * FROM cdm_demo_gold.Dim2StaffElectronicIdList;
SELECT * FROM cdm_demo_gold.Dim2StaffOtherIdList;
SELECT * FROM cdm_demo_gold.Dim2StaffNames;
SELECT * FROM cdm_demo_gold.Dim2StaffDemographics;
SELECT * FROM cdm_demo_gold.Bridge2StaffCountriesOfCitizenship;
SELECT * FROM cdm_demo_gold.Bridge2StaffCountriesOfResidency;
SELECT * FROM cdm_demo_gold.Bridge2StaffLanguages;
SELECT * FROM cdm_demo_gold.Dim2StaffReligiousEvent;
SELECT * FROM cdm_demo_gold.Dim2StaffPassport;
SELECT * FROM cdm_demo_gold.Dim2StaffAddressList;
SELECT * FROM cdm_demo_gold.Dim2StaffPhoneNumberList;
SELECT * FROM cdm_demo_gold.Dim2StaffEmailList;
SELECT * FROM cdm_demo_gold.Bridge2StaffHouseholdContactInfo;
SELECT * FROM cdm_demo_gold.Dim2StaffHouseholdContactAddressList;
SELECT * FROM cdm_demo_gold.Dim2StaffHouseholdContactPhoneNumberList;
SELECT * FROM cdm_demo_gold.Dim2StaffHouseholdContactEmailList;
SELECT * FROM cdm_demo_gold.Dim2StaffMostRecentNAPLANClassList;
SELECT * FROM cdm_demo_gold.Dim4StaffPersonalMostRecent;

-- LEAInfo (Local Education Authority) tables:

SELECT * FROM cdm_demo_gold.Dim1LEAInfo;
SELECT * FROM cdm_demo_gold.Dim2LEAAddressList;
SELECT * FROM cdm_demo_gold.Dim2LEAPhoneNumberList;
SELECT * FROM cdm_demo_gold.Dim2LEAContactInfo;
SELECT * FROM cdm_demo_gold.Dim3LEAContactAddressList;
SELECT * FROM cdm_demo_gold.Dim3LEAContactPhoneNumberList;
SELECT * FROM cdm_demo_gold.Dim3LEAContactEmailList;

-- SchoolInfo tables:

SELECT * FROM cdm_demo_gold.Dim2SchoolInfo;
SELECT * FROM cdm_demo_gold.Dim3SchoolACARAIdList;
SELECT * FROM cdm_demo_gold.Dim3SchoolOtherIdList;
SELECT * FROM cdm_demo_gold.Dim3SchoolFocus;
SELECT * FROM cdm_demo_gold.Dim3SchoolAddressList;
SELECT * FROM cdm_demo_gold.Dim3SchoolPhoneNumberList;
SELECT * FROM cdm_demo_gold.Dim3SchoolEmailList;
SELECT * FROM cdm_demo_gold.Dim3SchoolPrincipalPhoneNumberList;
SELECT * FROM cdm_demo_gold.Dim3SchoolPrincipalEmailList;
SELECT * FROM cdm_demo_gold.Dim3SchoolContactInfo;
SELECT * FROM cdm_demo_gold.Dim3SchoolCampus;
SELECT * FROM cdm_demo_gold.Dim3SchoolGroup;
SELECT * FROM cdm_demo_gold.Dim3SchoolYearLevels;
SELECT * FROM cdm_demo_gold.Dim3SchoolEnrollmentByYearLevel;
SELECT * FROM cdm_demo_gold.Dim4SchoolContactAddressList;
SELECT * FROM cdm_demo_gold.Dim4SchoolContactPhoneNumberList;
SELECT * FROM cdm_demo_gold.Dim4SchoolContactEmailList;

-- StudentPersonal tables:

SELECT * FROM cdm_demo_gold.Dim1StudentPersonal;
SELECT * FROM cdm_demo_gold.Dim1StudentHouseholdContactInfo;
SELECT * FROM cdm_demo_gold.Dim2StudentList;
SELECT * FROM cdm_demo_gold.Dim2StudentAlertMessages;
SELECT * FROM cdm_demo_gold.Dim2StudentMedicalAlertMessages;
SELECT * FROM cdm_demo_gold.Dim2StudentElectronicIdList;
SELECT * FROM cdm_demo_gold.Dim2StudentOtherIdList;
SELECT * FROM cdm_demo_gold.Dim2StudentNames;
SELECT * FROM cdm_demo_gold.Dim2StudentDemographics;
SELECT * FROM cdm_demo_gold.Bridge2StudentCountriesOfCitizenship;
SELECT * FROM cdm_demo_gold.Bridge2StudentCountriesOfResidency;
SELECT * FROM cdm_demo_gold.Bridge2StudentLanguages;
SELECT * FROM cdm_demo_gold.Dim2StudentReligiousEvent;
SELECT * FROM cdm_demo_gold.Dim2StudentPassport;
SELECT * FROM cdm_demo_gold.Dim2StudentAddressList;
SELECT * FROM cdm_demo_gold.Dim2StudentPhoneNumberList;
SELECT * FROM cdm_demo_gold.Dim2StudentEmailList;
SELECT * FROM cdm_demo_gold.Bridge2StudentHouseholdContactInfo;
SELECT * FROM cdm_demo_gold.Dim2StudentHouseholdContactAddressList;
SELECT * FROM cdm_demo_gold.Dim2StudentHouseholdContactPhoneNumberList;
SELECT * FROM cdm_demo_gold.Dim2StudentHouseholdContactEmailList;
SELECT * FROM cdm_demo_gold.Dim4StudentPersonalMostRecent;

-- StudentSchoolEnrollment tables:

SELECT * FROM cdm_demo_gold.Fact3StudentSchoolEnrollment;
SELECT * FROM cdm_demo_gold.Fact4StudentSchoolEnrollmentOtherCodes;
SELECT * FROM cdm_demo_gold.Fact4StudentSchoolEnrollmentStudentGroup;
SELECT * FROM cdm_demo_gold.Fact4StudentSchoolEnrollmentPublishingPermissions;
SELECT * FROM cdm_demo_gold.Fact6StudentSubjectChoice;
SELECT * FROM cdm_demo_gold.Fact6StudentSubjectChoiceOtherCode;

-- StaffAssignment tables:

SELECT * FROM cdm_demo_gold.Fact3StaffAssignment;
SELECT * FROM cdm_demo_gold.Fact4StaffAssignmentActivityExtension;
SELECT * FROM cdm_demo_gold.Fact4StaffAssignmentActivityExtensionOtherCode;
SELECT * FROM cdm_demo_gold.Fact4StaffAssignmentYearLevels;
SELECT * FROM cdm_demo_gold.Fact4StaffAssignmentCalendarSummaryList;
SELECT * FROM cdm_demo_gold.Fact6StaffAssignmentSubjectList;

-- StudentContactPersonal tables:

SELECT * FROM cdm_demo_gold.Dim1StudentContactPersonal;
SELECT * FROM cdm_demo_gold.Dim1StudentContactHouseholdContactInfo;
SELECT * FROM cdm_demo_gold.Dim2StudentContactPersonList;
SELECT * FROM cdm_demo_gold.Dim2StudentContactOtherIdList;
SELECT * FROM cdm_demo_gold.Dim2StudentContactNames;
SELECT * FROM cdm_demo_gold.Dim2StudentContactDemographics;
SELECT * FROM cdm_demo_gold.Bridge2StudentContactCountriesOfCitizenship;
SELECT * FROM cdm_demo_gold.Bridge2StudentContactCountriesOfResidency;
SELECT * FROM cdm_demo_gold.Bridge2StudentContactLanguages;
SELECT * FROM cdm_demo_gold.Dim2StudentContactReligiousEvent;
SELECT * FROM cdm_demo_gold.Dim2StudentContactPassport;
SELECT * FROM cdm_demo_gold.Dim2StudentContactAddressList;
SELECT * FROM cdm_demo_gold.Dim2StudentContactPhoneNumberList;
SELECT * FROM cdm_demo_gold.Dim2StudentContactEmailList;
SELECT * FROM cdm_demo_gold.Bridge2StudentContactHouseholdContactInfo;
SELECT * FROM cdm_demo_gold.Dim2StudentContactHouseholdContactAddressList;
SELECT * FROM cdm_demo_gold.Dim2StudentContactHouseholdContactPhoneNumberList;
SELECT * FROM cdm_demo_gold.Dim2StudentContactHouseholdContactEmailList;

-- StudentContactRelationship tables:

SELECT * FROM cdm_demo_gold.Fact3StudentContactRelationship;
SELECT * FROM cdm_demo_gold.Fact4StudentContactRelationshipHouseholdList;

-- Party, Identity, PersonPicture & PrivacyObligation(s) tables:

SELECT * FROM cdm_demo_gold.Dim2PartyList;
SELECT * FROM cdm_demo_gold.Dim3Identity;
SELECT * FROM cdm_demo_gold.Dim3PersonPicture;
SELECT * FROM cdm_demo_gold.Dim3PersonPrivacyObligationDocument;
SELECT * FROM cdm_demo_gold.Dim4IdentityAssertions;
SELECT * FROM cdm_demo_gold.Dim4IdentityPasswordList;
SELECT * FROM cdm_demo_gold.Dim4PersonPicturePublishingPermissions;
SELECT * FROM cdm_demo_gold.Dim4PersonPrivacySettingLocation;
SELECT * FROM cdm_demo_gold.Dim4PersonPrivacyDataDomain;
SELECT * FROM cdm_demo_gold.Dim4PersonPrivacyPermissionToParticipate;
SELECT * FROM cdm_demo_gold.Dim4PersonPrivacyApplicableLaw;
SELECT * FROM cdm_demo_gold.Dim5PersonPrivacyDataDomainShareWith;
SELECT * FROM cdm_demo_gold.Dim5PersonPrivacyDataDomainDoNotShareWith;

-- LearningResourcePackage tables:

SELECT * FROM cdm_demo_gold.Dim1LearningResourcePackage;

-- LearningResource tables:

SELECT * FROM cdm_demo_gold.Dim2LearningResource;
SELECT * FROM cdm_demo_gold.Dim3LearningResourceContacts;
SELECT * FROM cdm_demo_gold.Dim3LearningResourceYearLevels;
SELECT * FROM cdm_demo_gold.Dim3LearningResourceAustralianCurriculumStrandList;
SELECT * FROM cdm_demo_gold.Dim3LearningResourceSubjectAreaList;
SELECT * FROM cdm_demo_gold.Dim3LearningResourceMediaTypes;
SELECT * FROM cdm_demo_gold.Dim3LearningResourceApprovals;
SELECT * FROM cdm_demo_gold.Dim3LearningResourceEvaluations;
SELECT * FROM cdm_demo_gold.Dim3LearningResourceComponents;
SELECT * FROM cdm_demo_gold.Dim4LearningResourceContactNames;
SELECT * FROM cdm_demo_gold.Dim4LearningResourceContactAddresses;
SELECT * FROM cdm_demo_gold.Dim4LearningResourceContactPhoneNumbers;
SELECT * FROM cdm_demo_gold.Dim4LearningResourceContactEmails;
SELECT * FROM cdm_demo_gold.Dim4LearningResourceSubjectAreaOtherCodeList;
SELECT * FROM cdm_demo_gold.Dim4LearningResourceComponentTeachingLearningStrategies;
SELECT * FROM cdm_demo_gold.Dim4LearningResourceComponentAssociatedObjects;

-- EquipmentInfo tables:

SELECT * FROM cdm_demo_gold.Dim1EquipmentInfo;

-- RoomInfo tables:

SELECT * FROM cdm_demo_gold.Dim3RoomInfo;
SELECT * FROM cdm_demo_gold.Dim4RoomInfoStaffList;

-- ResourceList tables:

SELECT * FROM cdm_demo_gold.Dim4ResourceList;

-- LibraryPatronStatus tables:

SELECT * FROM cdm_demo_gold.Dim3LibraryPatronStatus;
SELECT * FROM cdm_demo_gold.Dim4LibraryPatronElectronicIdList;
SELECT * FROM cdm_demo_gold.Dim4LibraryPatronTransactionList;
SELECT * FROM cdm_demo_gold.Dim4LibraryPatronMessageList;
SELECT * FROM cdm_demo_gold.Dim5LibraryItemElectronicIdList;

-- TermInfo tables:

SELECT * FROM cdm_demo_gold.Dim3TermInfo;

-- SchoolCourseInfo tables:

SELECT * FROM cdm_demo_gold.Dim4SchoolCourseInfo;
SELECT * FROM cdm_demo_gold.Dim5SchoolCourseSubjectAreaList;
SELECT * FROM cdm_demo_gold.Dim6SchoolCourseSubjectAreaOtherCodes;

-- SectionInfo tables:

SELECT * FROM cdm_demo_gold.Dim5SectionInfo;
SELECT * FROM cdm_demo_gold.Dim6SectionInfoOtherCodes;

-- StudentSectionEnrollment tables:

SELECT * FROM cdm_demo_gold.Fact6StudentSectionEnrollment;

-- TimeTable tables:

SELECT * FROM cdm_demo_gold.Dim3TimeTable;
SELECT * FROM cdm_demo_gold.Dim4TimeTableDay;
SELECT * FROM cdm_demo_gold.Dim5TimeTablePeriod;

-- TimeTableSubject tables:

SELECT * FROM cdm_demo_gold.Dim5TimeTableSubject;
SELECT * FROM cdm_demo_gold.Dim6TimeTableSubjectOtherCodes;

-- TeachingGroup tables:

SELECT * FROM cdm_demo_gold.Dim6TeachingGroup;
SELECT * FROM cdm_demo_gold.Dim7TeachingGroupStudentList;
SELECT * FROM cdm_demo_gold.Dim7TeachingGroupTeacherList;
SELECT * FROM cdm_demo_gold.Dim8TeachingGroupPeriodList;

-- TimeTableCell tables:

SELECT * FROM cdm_demo_gold.Dim7TimeTableCell;
SELECT * FROM cdm_demo_gold.Dim8TimeTableCellTeacherCoverList;
SELECT * FROM cdm_demo_gold.Dim8TimeTableCellRoomList;

-- TimeTableContainer tables:

SELECT * FROM cdm_demo_gold.Dim1TimeTableContainer;
SELECT * FROM cdm_demo_gold.Dim4TimeTableContainerSchedule;
SELECT * FROM cdm_demo_gold.Dim5TimeTableContainerDay;
SELECT * FROM cdm_demo_gold.Dim7TimeTableContainerTeachingGroupScheduleList;
SELECT * FROM cdm_demo_gold.Dim8TimeTableContainerScheduleCellList;
SELECT * FROM cdm_demo_gold.Dim8TimeTableContainerTeachingGroupPeriodList;
SELECT * FROM cdm_demo_gold.Dim8TimeTableContainerTeachingGroupStudentList;
SELECT * FROM cdm_demo_gold.Dim8TimeTableContainerTeachingGroupTeacherList;
SELECT * FROM cdm_demo_gold.Dim9TimeTableContainerTeacherCoverList;
SELECT * FROM cdm_demo_gold.Dim9TimeTableContainerRoomList;

-- ScheduledActivity tables:

SELECT * FROM cdm_demo_gold.Dim8ScheduledActivity;
SELECT * FROM cdm_demo_gold.Dim9ScheduledActivityTeacherCoverList;
SELECT * FROM cdm_demo_gold.Dim9ScheduledActivityRoomList;
SELECT * FROM cdm_demo_gold.Dim9ScheduledActivityAddressList;
SELECT * FROM cdm_demo_gold.Dim9ScheduledActivityStudentList;
SELECT * FROM cdm_demo_gold.Dim9ScheduledActivityTeachingGroupList;
SELECT * FROM cdm_demo_gold.Dim9ScheduledActivityYearLevels;
SELECT * FROM cdm_demo_gold.Dim9ScheduledActivityChangeReasonList;

-- ResourceBooking tables:

SELECT * FROM cdm_demo_gold.Fact9ResourceBooking;
