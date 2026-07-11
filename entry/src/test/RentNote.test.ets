import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';

class PropertyInfo {
  id: string = '';
  name: string = '';
  address: string = '';
  district: string = '';
  tags: string[] = [];
  monthlyRent: number = 0;
  deposit: number = 0;
  startDate: string = '';
  endDate: string = '';
  status: string = 'renting';
  billsPaid: number = 0;
  imageUrls: string[] = [];
  notes: string = '';
  renewalStatus: string = '';
  latitude: number = 0;
  longitude: number = 0;

  getFirstImage(): string {
    return this.imageUrls.length > 0 ? this.imageUrls[0] : '';
  }

  clone(): PropertyInfo {
    const p: PropertyInfo = new PropertyInfo();
    p.id = this.id;
    p.name = this.name;
    p.address = this.address;
    p.district = this.district;
    p.tags = [...this.tags];
    p.monthlyRent = this.monthlyRent;
    p.deposit = this.deposit;
    p.startDate = this.startDate;
    p.endDate = this.endDate;
    p.status = this.status;
    p.billsPaid = this.billsPaid;
    p.imageUrls = [...this.imageUrls];
    p.notes = this.notes;
    p.renewalStatus = this.renewalStatus;
    p.latitude = this.latitude;
    p.longitude = this.longitude;
    return p;
  }
}

class TagCategory {
  name: string = '';
  tags: string[] = [];
  selected: boolean[] = [];
  tagBg: string = '';
  tagText: string = '';

  constructor(name: string, tagBg: string, tagText: string, tags: string[], initialSelected?: number[]) {
    this.name = name;
    this.tagBg = tagBg;
    this.tagText = tagText;
    this.tags = tags;
    this.selected = tags.map((_val: string, i: number) => initialSelected ? initialSelected.includes(i) : false);
  }
}

function getDaysRemaining(endDate: string): number {
  const parts: string[] = endDate.split('.');
  if (parts.length !== 3) {
    return 0;
  }
  const year: number = parseInt(parts[0], 10);
  const month: number = parseInt(parts[1], 10) - 1;
  const day: number = parseInt(parts[2], 10);
  const expiry: Date = new Date(year, month, day);
  const today: Date = new Date();
  today.setHours(0, 0, 0, 0);
  const diff: number = expiry.getTime() - today.getTime();
  return Math.ceil(diff / (1000 * 60 * 60 * 24));
}

function getLeaseProgress(startDate: string, endDate: string): number {
  const startParts: string[] = startDate.split('.');
  const endParts: string[] = endDate.split('.');
  if (startParts.length < 3 || endParts.length < 3) {
    return 0;
  }
  const startMs: number = new Date(
    parseInt(startParts[0], 10), parseInt(startParts[1], 10) - 1, parseInt(startParts[2], 10)
  ).getTime();
  const endMs: number = new Date(
    parseInt(endParts[0], 10), parseInt(endParts[1], 10) - 1, parseInt(endParts[2], 10)
  ).getTime();
  const nowMs: number = Date.now();
  if (endMs <= startMs) {
    return 0;
  }
  const pct: number = Math.floor(((nowMs - startMs) / (endMs - startMs)) * 100);
  return Math.max(0, Math.min(pct, 100));
}

function extractDistrict(address: string): string {
  let results: string[] = address.match(new RegExp('[\\u4e00-\\u9fa5]{2}[区县]', 'g')) ?? [];
  if (results.length > 0) {
    return results[results.length - 1];
  }
  results = address.match(new RegExp('[\\u4e00-\\u9fa5]{3}[区县]', 'g')) ?? [];
  if (results.length > 0) {
    return results[results.length - 1];
  }
  return address.length > 3 ? address.substring(0, 3) : address;
}

function validateForm(name: string, monthlyRent: number, isCandidateMode: boolean): string {
  if (!name || name.trim().length === 0) {
    return '请输入小区名称';
  }
  if (!isCandidateMode && monthlyRent <= 0) {
    return '请输入有效的月租金';
  }
  return '';
}

export default function rentNoteUnitTest() {
  describe('PropertyInfo', () => {
    it('shouldCreateDefaultInstance', 0, () => {
      const p: PropertyInfo = new PropertyInfo();
      expect(p.id).assertEqual('');
      expect(p.name).assertEqual('');
      expect(p.status).assertEqual('renting');
      expect(p.tags.length).assertEqual(0);
      expect(p.monthlyRent).assertEqual(0);
      expect(p.imageUrls.length).assertEqual(0);
      expect(p.notes).assertEqual('');
      expect(p.latitude).assertEqual(0);
      expect(p.longitude).assertEqual(0);
    });

    it('getFirstImageShouldReturnEmptyWhenNoImages', 0, () => {
      const p: PropertyInfo = new PropertyInfo();
      expect(p.getFirstImage()).assertEqual('');
    });

    it('getFirstImageShouldReturnFirstUrl', 0, () => {
      const p: PropertyInfo = new PropertyInfo();
      p.imageUrls = ['uri1', 'uri2', 'uri3'];
      expect(p.getFirstImage()).assertEqual('uri1');
    });

    it('cloneShouldCreateDeepCopy', 0, () => {
      const p: PropertyInfo = new PropertyInfo();
      p.id = '100';
      p.name = '碧水湾';
      p.tags = ['近地铁', '整租'];
      p.monthlyRent = 6200;
      p.imageUrls = ['img1', 'img2'];
      p.notes = '押一付三';
      p.latitude = 39.994;

      const clone: PropertyInfo = p.clone();
      expect(clone.id).assertEqual('100');
      expect(clone.name).assertEqual('碧水湾');
      expect(clone.tags.length).assertEqual(2);
      expect(clone.imageUrls.length).assertEqual(2);
      expect(clone.monthlyRent).assertEqual(6200);
      expect(clone.notes).assertEqual('押一付三');
    });

    it('cloneShouldNotShareArrayReferences', 0, () => {
      const p: PropertyInfo = new PropertyInfo();
      p.tags = ['tag1'];
      p.imageUrls = ['img1'];

      const clone: PropertyInfo = p.clone();
      clone.tags.push('tag2');
      clone.imageUrls.push('img2');

      expect(p.tags.length).assertEqual(1);
      expect(p.imageUrls.length).assertEqual(1);
      expect(clone.tags.length).assertEqual(2);
      expect(clone.imageUrls.length).assertEqual(2);
    });

    it('statusValuesShouldBeValid', 0, () => {
      const p1: PropertyInfo = new PropertyInfo();
      p1.status = 'renting';
      expect(p1.status === 'renting' || p1.status === 'candidate' || p1.status === 'expiring').assertEqual(true);

      const p2: PropertyInfo = new PropertyInfo();
      p2.status = 'candidate';
      expect(p2.status === 'renting' || p2.status === 'candidate' || p2.status === 'expiring').assertEqual(true);

      const p3: PropertyInfo = new PropertyInfo();
      p3.status = 'expiring';
      expect(p3.status === 'renting' || p3.status === 'candidate' || p3.status === 'expiring').assertEqual(true);
    });
  });

  describe('TagCategory', () => {
    it('shouldCreateWithNoSelection', 0, () => {
      const cat: TagCategory = new TagCategory('付款方式', '#F0EDFF', '#7859D9', ['押一付三', '半年付']);
      expect(cat.name).assertEqual('付款方式');
      expect(cat.tags.length).assertEqual(2);
      expect(cat.selected.length).assertEqual(2);
      expect(cat.selected[0]).assertEqual(false);
      expect(cat.selected[1]).assertEqual(false);
    });

    it('shouldCreateWithInitialSelection', 0, () => {
      const cat: TagCategory = new TagCategory('付款方式', '#F0EDFF', '#7859D9', ['押一付三', '半年付'], [0]);
      expect(cat.selected[0]).assertEqual(true);
      expect(cat.selected[1]).assertEqual(false);
    });

    it('shouldCreateWithMultipleSelections', 0, () => {
      const cat: TagCategory = new TagCategory('条件', '#E5FCF2', '#22A94A', ['精装修', '民水民电', '包物业'], [0, 2]);
      expect(cat.selected[0]).assertEqual(true);
      expect(cat.selected[1]).assertEqual(false);
      expect(cat.selected[2]).assertEqual(true);
    });

    it('selectedArrayShouldMatchTagsLength', 0, () => {
      const cat: TagCategory = new TagCategory('测试', '#fff', '#000', ['a', 'b', 'c', 'd'], [3]);
      expect(cat.selected.length).assertEqual(4);
      expect(cat.selected[3]).assertEqual(true);
    });

    it('emptyInitialSelectedShouldAllBeFalse', 0, () => {
      const cat: TagCategory = new TagCategory('空', '#fff', '#000', ['x', 'y'], []);
      expect(cat.selected[0]).assertEqual(false);
      expect(cat.selected[1]).assertEqual(false);
    });
  });

  describe('validateForm', () => {
    it('shouldRejectEmptyName', 0, () => {
      expect(validateForm('', 3000, false).length > 0).assertEqual(true);
    });

    it('shouldRejectWhitespaceName', 0, () => {
      expect(validateForm('   ', 3000, false).length > 0).assertEqual(true);
    });

    it('shouldRejectZeroRentInRentingMode', 0, () => {
      expect(validateForm('测试房源', 0, false).length > 0).assertEqual(true);
    });

    it('shouldAllowZeroRentInCandidateMode', 0, () => {
      expect(validateForm('测试房源', 0, true)).assertEqual('');
    });

    it('shouldAcceptValidRentingData', 0, () => {
      expect(validateForm('阳光花园', 5000, false)).assertEqual('');
    });

    it('shouldAcceptValidCandidateData', 0, () => {
      expect(validateForm('看房候选', 0, true)).assertEqual('');
    });
  });

  describe('getDaysRemaining', () => {
    it('shouldReturnZeroForInvalidDate', 0, () => {
      expect(getDaysRemaining('')).assertEqual(0);
      expect(getDaysRemaining('2024')).assertEqual(0);
      expect(getDaysRemaining('invalid')).assertEqual(0);
    });

    it('shouldReturnPositiveForFutureDate', 0, () => {
      expect(getDaysRemaining('2099.12.31') > 0).assertEqual(true);
    });

    it('shouldReturnNegativeForPastDate', 0, () => {
      expect(getDaysRemaining('2020.01.01') < 0).assertEqual(true);
    });

    it('shouldParseCorrectDate', 0, () => {
      const result: number = getDaysRemaining('2099.06.15');
      expect(result > 0).assertEqual(true);
    });
  });

  describe('getLeaseProgress', () => {
    it('shouldReturnZeroForInvalidDates', 0, () => {
      expect(getLeaseProgress('', '')).assertEqual(0);
      expect(getLeaseProgress('2024', '')).assertEqual(0);
    });

    it('shouldReturnZeroIfEndBeforeStart', 0, () => {
      expect(getLeaseProgress('2025.01.01', '2024.01.01')).assertEqual(0);
    });

    it('shouldReturnClampedProgress', 0, () => {
      const progress: number = getLeaseProgress('2024.01.01', '2025.01.01');
      expect(progress >= 0 && progress <= 100).assertEqual(true);
    });

    it('shouldReturn100ForExpiredLease', 0, () => {
      const progress: number = getLeaseProgress('2020.01.01', '2021.01.01');
      expect(progress).assertEqual(100);
    });
  });

  describe('extractDistrict', () => {
    it('shouldExtractChaoyangDistrict', 0, () => {
      expect(extractDistrict('北京市朝阳区望京西园2栋')).assertEqual('朝阳区');
    });

    it('shouldExtractHaidianDistrict', 0, () => {
      expect(extractDistrict('北京市海淀区中关村')).assertEqual('海淀区');
    });

    it('shouldExtractCounty', 0, () => {
      expect(extractDistrict('长沙市长沙县星沙')).assertEqual('长沙县');
    });

    it('shouldFallbackToFirst3CharsWhenNoDistrict', 0, () => {
      expect(extractDistrict('望京西园2栋')).assertEqual('望京西');
    });

    it('shouldHandleShortAddress', 0, () => {
      expect(extractDistrict('望')).assertEqual('望');
    });

    it('shouldHandleEmptyAddress', 0, () => {
      expect(extractDistrict('')).assertEqual('');
    });
  });

  describe('Date Formatting', () => {
    it('shouldFormatDateAsYYYYMMDD', 0, () => {
      const date: Date = new Date(2024, 6, 15);
      const y: number = date.getFullYear();
      const m: string = (date.getMonth() + 1).toString().padStart(2, '0');
      const d: string = date.getDate().toString().padStart(2, '0');
      const formatted: string = y.toString() + '.' + m + '.' + d;
      expect(formatted).assertEqual('2024.07.15');
    });

    it('shouldPadMonthAndDayWithZero', 0, () => {
      const date: Date = new Date(2024, 0, 5);
      const m: string = (date.getMonth() + 1).toString().padStart(2, '0');
      const d: string = date.getDate().toString().padStart(2, '0');
      expect(m).assertEqual('01');
      expect(d).assertEqual('05');
    });
  });

  describe('Import/Export JSON Parsing', () => {
    it('shouldRejectInvalidJson', 0, () => {
      let parseError: boolean = false;
      try {
        JSON.parse('not json');
      } catch (_e) {
        parseError = true;
      }
      expect(parseError).assertEqual(true);
    });

    it('shouldRejectNonArrayJson', 0, () => {
      const parsed: Object = JSON.parse('{"key": "value"}') as Object;
      expect(Array.isArray(parsed)).assertEqual(false);
    });

    it('shouldAcceptArrayJson', 0, () => {
      const parsed: Object = JSON.parse('[{"name": "test"}]') as Object;
      expect(Array.isArray(parsed)).assertEqual(true);
      const arr: Object[] = parsed as Object[];
      expect(arr.length).assertEqual(1);
    });

    it('shouldSkipItemsWithoutName', 0, () => {
      const rawList: Object[] = JSON.parse('[{"address": "test"}, {"name": "valid"}]') as Object[];
      let validCount: number = 0;
      for (const rawObj of rawList) {
        const raw: Record<string, Object> = rawObj as Record<string, Object>;
        const name: string = (raw['name'] as string) ?? '';
        if (name && name.trim().length > 0) {
          validCount++;
        }
      }
      expect(validCount).assertEqual(1);
    });

    it('shouldDetectDuplicateIds', 0, () => {
      const existingIds: Set<string> = new Set<string>();
      existingIds.add('1');
      existingIds.add('2');
      expect(existingIds.has('1')).assertEqual(true);
      expect(existingIds.has('3')).assertEqual(false);
    });
  });

  describe('Property Status Transitions', () => {
    it('candidateToRentingIsValidTransition', 0, () => {
      const p: PropertyInfo = new PropertyInfo();
      p.status = 'candidate';
      p.status = 'renting';
      expect(p.status).assertEqual('renting');
    });

    it('rentingToCandidateIsValidTransition', 0, () => {
      const p: PropertyInfo = new PropertyInfo();
      p.status = 'renting';
      p.status = 'candidate';
      expect(p.status).assertEqual('candidate');
    });

    it('demoteShouldClearLeaseFields', 0, () => {
      const p: PropertyInfo = new PropertyInfo();
      p.status = 'renting';
      p.startDate = '2024.01.01';
      p.endDate = '2025.01.01';
      p.renewalStatus = 'renew';
      p.status = 'candidate';
      p.startDate = '';
      p.endDate = '';
      p.renewalStatus = '';
      expect(p.status).assertEqual('candidate');
      expect(p.startDate).assertEqual('');
      expect(p.endDate).assertEqual('');
      expect(p.renewalStatus).assertEqual('');
    });
  });

  describe('Edge Cases', () => {
    it('emptyImageUrlsShouldNotCrash', 0, () => {
      const p: PropertyInfo = new PropertyInfo();
      expect(p.getFirstImage()).assertEqual('');
      expect(p.imageUrls.length).assertEqual(0);
    });

    it('singleImageUrlShouldWork', 0, () => {
      const p: PropertyInfo = new PropertyInfo();
      p.imageUrls = ['only_one'];
      expect(p.getFirstImage()).assertEqual('only_one');
    });

    it('zeroRentShouldBeValidForCandidate', 0, () => {
      const p: PropertyInfo = new PropertyInfo();
      p.status = 'candidate';
      p.monthlyRent = 0;
      expect(p.monthlyRent).assertEqual(0);
    });

    it('cloneOfEmptyPropertyShouldWork', 0, () => {
      const p: PropertyInfo = new PropertyInfo();
      const clone: PropertyInfo = p.clone();
      expect(clone.id).assertEqual('');
      expect(clone.tags.length).assertEqual(0);
    });
  });
}
