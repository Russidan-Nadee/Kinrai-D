import { IsInt } from 'class-validator';

export class RemoveDislikeDto {
  @IsInt()
  menu_id: number;
}