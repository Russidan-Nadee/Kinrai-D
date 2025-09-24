import { IsInt } from 'class-validator';

export class RemoveRestrictionDto {
  @IsInt()
  dietary_restriction_id: number;
}
