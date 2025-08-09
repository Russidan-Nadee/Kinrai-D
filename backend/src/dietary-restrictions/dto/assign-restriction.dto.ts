import { IsInt } from 'class-validator';

export class AssignRestrictionDto {
  @IsInt()
  dietary_restriction_id: number;
}