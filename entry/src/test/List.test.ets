import localUnitTest from './LocalUnit.test';
import rentNoteUnitTest from './RentNote.test';

export default function testsuite() {
  localUnitTest();
  rentNoteUnitTest();
}
